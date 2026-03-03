################################################################################
#' InVEST Input Data Preparation  using BASEMAP Script
#'
#' This script prepares input data for INVEST pollination model calculations 
#' using BASEMAP and PALUD data. It processes agricultural land use data and 
#' creates the necessary raster and vector inputs for ecosystem service modeling.
#'
#' @title 2_INVEST_INPUTDATA_PALUDorg.R
#' @author Saskia Osterkamp
#' @date 2025-10-27
#' @version 2.1.0 (Refactored, repair invalid geometries)
#' @license GPL-3
#' 
#' @description
#' The script processes PALUD (agricultural land use) data and intersects it with
#' BASEMAP to create input files for the INVEST pollination model. It handles
#' multiple scenarios (Org, NoOrg, AllOrg) representing different organic farming
#' implementations and creates both raster and vector outputs along with JSON
#' configuration files.
#'
#' @details
#' Key processing steps:
#' 1. Load and preprocess PALUD and BASEMAP data
#' 2. Intersect spatial datasets and standardize attributes
#' 3. Create land cover rasters at 20m resolution
#' 4. Generate field shapefiles for pollinator-dependent crops
#' 5. Create JSON configuration files for INVEST model runs
#'
#' @note
#' Requires PALUD output files and BASEMAP data in specified directory structure.
#' See README.md for complete setup instructions.
#'
#' @examples
#' # Command line usage:
#' # Rscript script.R workbench folder year sim run_allorg run_noorg create_json SNH_id
#' 
#' # Interactive usage:
#' # source("script.R")
#' # results <- main()
################################################################################

# ---- SETUP AND DEPENDENCIES ----
#' @section Dependencies
#' Required R packages for spatial processing, data manipulation, and file I/O

rm(list=ls()) 
start <- Sys.time()

# Load required libraries with error handling
required_packages <- c("sf", "terra", "dplyr", "mapview", "stringr", "jsonlite")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    stop(paste("Required package", pkg, "is not installed. Please install it using: install.packages('", pkg, "')", sep = ""))
  }
}


# ---- PARAMETER HANDLING ----
#' Get and validate script parameters
#'
#' Handles both command-line arguments and manual parameter setting for 
#' interactive use. Validates parameter types and provides informative output.
#'
#' @return list A named list containing all script parameters
#' @details
#' Command line parameters (in order):
#' \itemize{
#'   \item workbench: Base working directory path
#'   \item folder: Subdirectory name for scenario
#'   \item year: Target year for analysis (e.g., "2030")
#'   \item sim: Additional identifier for file naming
#'   \item run_allorg: Logical, whether to process AllOrg scenario
#'   \item run_noorg: Logical, whether to process NoOrg scenario  
#'   \item create_json: Logical, whether to create JSON config files
#'   \item SNH_id: Semi-natural habitat identifier (optional)
#' }
#' @examples
#' params <- get_parameters()
#' print(params$workbench)
get_parameters <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) > 0) {
    # Validate argument count
    if (length(args) != 8) {
      stop("Expected 8 arguments, got ", length(args), 
           ". Usage: workbench folder year sim run_allorg run_noorg create_json SNH_id")
    }
    
    # Parse command line arguments
    params <- list(
      workbench = args[1],
      folder = args[2],
      year = args[3],
      sim = args[4],
      run_allorg = as.logical(args[5]),
      run_noorg = as.logical(args[6]),
      create_json = as.logical(args[7]),
      SNH_id = args[8]
    )
    
    
    # Validate logical parameters
    if (is.na(params$run_allorg) || is.na(params$run_noorg) || is.na(params$create_json)) {
      stop("Boolean parameters must be TRUE or FALSE")
    }
    
  } else {
    # Default parameters for interactive/development use
    message("No command line arguments provided. Using default parameters for development.")
    params <- list(
      workbench = "C:/git/HALUMI_poll/InVEST/Input/EE-v2",
      folder = "base",
      year = "base",
      sim = "BAU",
      run_allorg = FALSE,
      run_noorg = TRUE,
      create_json = FALSE,
      SNH_id = "" # "SNH1"
    )
  }
  
  # Validate required paths exist
  if (!dir.exists(params$workbench)) {
    stop("Workbench directory does not exist: ", params$workbench)
  }
  
  # Print parameters for verification
  message("=== SCRIPT PARAMETERS ===")
  for (name in names(params)) {
    message(sprintf("  %-15s = %s", name, params[[name]]))
  }
  message("========================")
  
  return(params)
}


# ---- CONFIGURATION SETUP ----
#' Set up configuration constants and derived paths
#'
#' Creates a configuration object with all necessary paths, constants, and
#' settings derived from input parameters.
#'
#' @param params list Parameter list from get_parameters()
#' @return list Configuration object with paths and constants
#' @details
#' Configuration includes:
#' \itemize{
#'   \item File paths for input and output data
#'   \item Regional settings (currently Hohenlohe)
#'   \item Target crop codes for pollinator-dependent agriculture
#'   \item Raster resolution and projection parameters
#' }
#' @examples
#' config <- setup_config(params)
#' print(config$wdir)
setup_config <- function(params) {
  # Ensure the directory exists
  config <- list(
    # Directory paths
    wdir = file.path(params$workbench, params$folder),
    region = "Hohenlohe",  # Study region
    filepathIN = "C:/git/HALUMI_poll/InVEST/Input",
    
    # Raster settings
    resolution = 10,  # meters
    crs_string = "+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs",
    na_fill_value = 80,
    
    # Target crop codes for pollinator-dependent crops
    target_ncs = c(
      "000311INV", "00311oINV", # Winter rapeseed (conv. & organic)
      "000321INV", "00321oINV", # Other oilseeds/soybeans (conv. & organic)  
      "000707INV", "00707oINV", # Strawberries (conv. & organic)
      "000821INV"               # Apples
    )
  )
  
  # Create output directory if it doesn't exist
  if (!dir.exists(config$wdir)) {
    dir.create(config$wdir, recursive = TRUE)
    message("Created output directory: ", config$wdir)
  }
  
  return(config)
}
    
    

# ---- LOAD LIBRARIES ----
suppressMessages({  
  library(sf)
  library(terra)
  library(dplyr)
  library(mapview)
  library(stringr)
  library(jsonlite)
}
)


# ---- DATA LOADING FUNCTIONS ----
#' Load all required input datasets
#'
#' Loads PALUD agricultural data, BASEMAP, and parameter tables required
#' for INVEST model preparation. Includes data validation and preprocessing.
#'
#' @param config list Configuration object from setup_config()
#' @param params list Parameter object from get_parameters()
#' @return list Named list containing all loaded datasets
#' @details
#' Loaded datasets include:
#' \itemize{
#'   \item palud_raw: Raw PALUD agricultural land use data
#'   \item basemap: BASEMAP spatial reference data
#'   \item invest_param: INVEST model parameters
#'   \item p_managed: Managed pollinator proportions by region
#'   \item half_sat: Half-saturation coefficients by crop type
#' }
#' @examples
#' data <- load_base_data(config, params)
#' print(nrow(data$palud_raw))
load_base_data <- function(config, params) {
  message("=== LOADING INPUT DATA ===")
  
  # Construct file paths  
  palud_file <- file.path(config$filepathIN, "Invekos_BW", 
                          paste0("PALUD_shapefile_", params$sim, params$year, ".shp"))
  basemap_file <- "C:/git/HALUMI_poll/Input/basemap/BASEMAP_InVEST_Hohenlohe_diff_AGS.shp"
  
  # read InVEST dependence ratios
  if(file.exists(file.path(params$workbench, "InVEST_param.csv"))){
    invest_param_file <- file.path(params$workbench, "InVEST_param.csv")
  } else{
    invest_param_file <- "C:/git/HALUMI_poll/Input/parameters/InVEST_param.csv"
  }
  
  if(file.exists(file.path(params$workbench, "InVEST_p_managed.csv"))){  
    p_managed_file <- file.path(params$workbench, "InVEST_p_managed.csv")
  } else{
    p_managed_file <- "C:/git/HALUMI_poll/Input/parameters/InVEST_p_managed.csv"
  }
  
  if(file.exists(file.path(params$workbench, "InVEST_param_h.csv"))){
    half_sat_file <- file.path(params$workbench, "InVEST_param_h.csv")
  } else{
    half_sat_file <- "C:/git/HALUMI_poll/Input/parameters/InVEST_param_h.csv"
  }
  
  # Validate file existence
  required_files <- c(palud_file, basemap_file, invest_param_file, p_managed_file)
  missing_files <- required_files[!file.exists(required_files)]
  if (length(missing_files) > 0) {
    stop("Missing required files:\n", paste(missing_files, collapse = "\n"))
  }
  
  # Load spatial data
  message("Loading PALUD data: ", basename(palud_file))
  palud_raw <- st_read(palud_file, quiet = TRUE)
  message("  → Loaded ", nrow(palud_raw), " features")
  
  message("Loading BASEMAP data: ", basename(basemap_file))
  basemap <- st_read(basemap_file, quiet = TRUE)
  message("  → Loaded ", nrow(basemap), " features")
  
  # Load parameter tables
  message("Loading INVEST parameters...")
  invest_param <- read.csv(invest_param_file, stringsAsFactors = FALSE)
  
  p_managed <- read.csv(p_managed_file, stringsAsFactors = FALSE)
  p_managed$AGS <- as.character(paste0("0", p_managed$AGS))  # Format AGS codes
  
  # Define half-saturation constants by crop type
  # These values represent ecological parameters for pollinator effectiveness
  half_sat <- read.csv(half_sat_file, stringsAsFactors = FALSE)

  
  message("=== DATA LOADING COMPLETE ===\n")
  
  return(list(
    palud_raw = palud_raw,
    basemap = basemap,
    invest_param = invest_param,
    p_managed = p_managed,
    half_sat = half_sat
  ))
}


# ---- SPATIAL PROCESSING ----
#' Process and intersect PALUD with BASEMAP data
#'
#' Cleans PALUD agricultural data, intersects it with BASEMAP reference data,
#' and prepares a unified spatial dataset for INVEST processing.
#'
#' @param palud_raw sf object Raw PALUD data from load_base_data()
#' @param basemap sf object BASEMAP reference data
#' @return sf object Processed and cleaned spatial polygons
#' @details
#' Processing steps:
#' \enumerate{
#'   \item Clean and standardize PALUD column structure
#'   \item Create standardized land use codes with "INV" suffix
#'   \item Transform coordinate systems for spatial intersection
#'   \item Combine PALUD and BASEMAP features
#'   \item Extract only polygon geometries
#'   \item Pad land use codes to standard 9-character format
#' }
#' @examples
#' poly <- process_palud_basemap(data$palud_raw, data$basemap)
#' print(paste("Processed", nrow(poly), "polygons"))
process_palud_basemap <- function(palud_raw, basemap) {
  message("=== PROCESSING SPATIAL DATA ===")
  
  # Clean PALUD data - select relevant columns and remove NAs
  message("Cleaning PALUD data...")
  palud <- palud_raw[, c(2, 14)]  # Select NC and AGS columns
  palud <- palud[!is.na(palud$NC), ]
  message("  → Retained ", nrow(palud), " valid records after NA removal")
  
  # Create standardized land use codes
  palud$nc2 <- paste0(palud$NC, "INV")
  palud2 <- palud %>%
    dplyr::select(c("nc2", "AGS")) %>%
    rename("nc" = "nc2")
  
  # Ensure coordinate system compatibility
  message("Transforming coordinate systems...")
  palud2 <- st_transform(palud2, st_crs(basemap))
  
  # Combine PALUD and BASEMAP data
  message("Intersecting PALUD with BASEMAP...")
  invekos_palud <- rbind(palud2, basemap)
  message("  → Combined dataset has ", nrow(invekos_palud), " features")
  
  # Standardize land use codes to 9 characters with leading zeros
  invekos_palud$nc <- str_pad(invekos_palud$nc, width = 9, side = "left", pad = "0")
  
  # Extract only polygon geometries (remove points, lines, etc.)
  message("Extracting polygon geometries...")
  poly <- st_collection_extract(invekos_palud, type = "POLYGON")
  message("  → Final dataset: ", nrow(poly), " polygon features")
  
  # Validate geometry types
  geom_types <- unique(st_geometry_type(poly))
  message("  → Geometry types: ", paste(geom_types, collapse = ", "))
  
  message("=== SPATIAL PROCESSING COMPLETE ===\n")
  return(poly)
}


# ---- SCENARIO PROCESSING ----
#' Process a single scenario (Org/NoOrg/AllOrg)
#'
#' Main processing function that handles data preparation for one scenario.
#' Merges biophysical parameters, calculates dependencies, creates outputs.
#'
#' @param poly sf object Processed polygon data from process_palud_basemap()
#' @param suffix character Scenario identifier ("Org", "NoOrg", "AllOrg")
#' @param config list Configuration object
#' @param params list Parameter object  
#' @param data list All loaded datasets
#' @return list of sf objects: Raster 
#'                             Final processed shapefile for the scenario
#'                             json file (optional)
#' @details
#' Processing workflow:
#' \enumerate{
#'   \item Load scenario-specific biophysical table  
#'   \item Merge spatial data with biophysical parameters
#'   \item Rename columns to INVEST-compatible format
#'   \item Calculate pollinator dependency values by crop type
#'   \item Create land cover raster
#'   \item Generate field shapefiles 
#'   \item Create JSON configuration (if requested)
#' }
#' @examples
#' result <- process_scenario(poly, "Org", config, params, data)
process_scenario <- function(poly, suffix, config, params, data) {
  message("=== PROCESSING SCENARIO: ", suffix, " ===")
  
  # Load scenario-specific biophysical table
  bio_table_path <- file.path(params$workbench, 
                              paste0("biophisical_table_", suffix, 
                                     ifelse(params$SNH_id == "", "", 
                                            paste0("_", params$SNH_id)), 
                                     ".csv"))
  
  if (!file.exists(bio_table_path)) {
    stop("Biophysical table not found: ", bio_table_path)
  }
  
  message("Loading biophysical table: ", basename(bio_table_path))
  bio_table <- read.csv(bio_table_path, stringsAsFactors = FALSE)
  message("  → ", nrow(bio_table), " parameter rows loaded")
  
  # Merge spatial data with biophysical parameters
  message("Merging spatial data with biophysical parameters...")
  inputshape <- merge(poly, bio_table, by = "nc")
  message("  → ", nrow(inputshape), " features after merge")
  
  # Rename columns to INVEST-compatible format and add calculated fields
  inputshape <- inputshape %>%
    rename(
      crop_type = group,
      fr_spring = floral_resources_spring_index,
      fr_summer = floral_resources_summer_index,
      n_ground = nesting_ground_availability_index,
      n_cavity = nesting_cavity_availability_index,
      FA = Floral_availability,      # Max 10 chars for shapefile
      NS = Nesting_suitability       # Max 10 chars for shapefile
    ) %>%
    mutate(
      season = "spring",  # Default season for analysis
      
      # Calculate pollinator dependency by crop type
      # Based on literature values for each crop's reliance on pollinators
      p_dep = case_when(
        nc == "000311INV" | nc == "00311oINV" ~ data$invest_param$p_dep_WR,   # Rapeseed
        nc == "000321INV" | nc == "00321oINV" ~ data$invest_param$p_dep_SB,   # Soybeans
        nc == "000707INV" | nc == "00707oINV" ~ data$invest_param$p_dep_ERD,  # Strawberries  
        nc == "000821INV" ~ data$invest_param$p_dep_AP,                       # Apples
        TRUE ~ 0  # No dependency for other crops
      )
    )
  
  # Repair geometries
  inputshape <- repair_geometries(inputshape)
  
  # Create outputs
  raster_output <- create_raster(inputshape, config, params, suffix)
  invekos_file <- create_field_shapefiles(inputshape, config, params, suffix, data)
  
  # Create JSON configuration if requested
  if (params$create_json) {
    create_json_config(config, params, suffix, invekos_file, raster_output)
  }
  
  message("=== SCENARIO ", suffix, " COMPLETE ===\n")
  return(list(
    inputshape = inputshape,
    raster = raster_output,
    invekos = invekos_file,
    json = if (params$create_json) {
      file.path(params$workbench, params$folder, paste0("pollination_", params$sim, suffix, params$SNH_id, ".json"))
    } else {
      NULL
    }
  ))
  
}

# ---- REPAIR GEOMETRIES ----
#' Repairs a shapefile
#' 
#' @param shp sf object input shapefile containing fields
#' @return repaired shapefile
#' @examples
#' result <- repair_geometries(shp)
repair_geometries <- function(shp) {
  cat("Repair geometries...\n")
  
  # Method 1: st_make_valid (meist ausreichend)
  shp_repaired <- st_make_valid(shp)
  
  # Method 2: Buffer with 0 (alternative Reparaturmethode)
  # shp_repaired <- st_buffer(shp, 0)
  
  # Method 3: lwgeom_make_valid (erweitertes Reparieren)
  # shp_repaired <- st_make_valid(shp, method = "structured")
  
  # Prüfen ob Reparatur erfolgreich war
  still_invalid <- sum(!st_is_valid(shp_repaired))
  if (still_invalid > 0) {
    warning(paste(still_invalid, "Geometries NOT repaired!"))
  } else {
    cat("Success: Geometries repaired!\n")
  }
  
  return(shp_repaired)
}

# ---- RASTER CREATION ----  
#' Create land cover raster for INVEST model
#'
#' Converts vector land use data to raster format required by INVEST.
#' Uses standardized resolution, projection, and handles missing values.
#'
#' @param inputshape sf object Processed land use shapefile
#' @param config list Configuration object with raster settings
#' @param params list Parameter object for file naming
#' @param suffix character Scenario identifier
#' @return character Path to created raster file
#' @details
#' Raster specifications:
#' \itemize{
#'   \item Resolution: 20m x 20m pixels
#'   \item Projection: UTM Zone 32N (EPSG:25832)
#'   \item Data type: 16-bit signed integer
#'   \item Field: lucode (standardized land use codes)
#'   \item NA handling: Filled with water body code (80)
#' }
#' @examples
#' raster_path <- create_raster(inputshape, config, params, "Org")
create_raster <- function(inputshape, config, params, suffix) {
  message("Creating land cover raster...")
  
  # Create raster template with specified resolution
  template <- rast(vect(inputshape), res = config$resolution)
  
  # Rasterize using land use codes
  message("  → Rasterizing ", nrow(inputshape), " features at ", config$resolution, "m resolution")
  CS_raster <- terra::rasterize(
    vect(inputshape), 
    template, 
    field = "lucode",           # Use standardized land use codes
    datatype = 'INT2S',         # 16-bit signed integer
    crs = config$crs_string     # UTM projection
  )
  
  # Crop to exact extent and handle missing values
  CS_raster_final <- terra::crop(CS_raster, vect(inputshape))
  
  # Fill NA values with water body code
  na_count <- sum(is.na(values(CS_raster_final)), na.rm = TRUE)
  if (na_count > 0) {
    message("  → Filling ", na_count, " NA pixels with water body code (", config$na_fill_value, ")")
    CS_raster_final[is.na(CS_raster_final)] <- config$na_fill_value
  }
  
  # Save raster with standardized naming
  raster_output <- file.path(config$wdir, 
                             paste0("RASTER", config$region, if(params$year == "base") "" else params$sim, 
                                    params$year, suffix, ".tiff"))
  
  writeRaster(CS_raster_final, raster_output, overwrite = TRUE)
  message("  → Raster saved: ", basename(raster_output))
  message("  → Dimensions: ", nrow(CS_raster_final), " x ", ncol(CS_raster_final), " pixels")
  message("  → Extent: ", paste(as.vector(ext(CS_raster_final)), collapse = ", "))
  
  return(raster_output)
}


# ---- FIELD SHAPEFILE CREATION ----
#' Create field shapefiles for INVEST pollination model
#'
#' Generates vector datasets of agricultural fields with pollinator-related
#' attributes. Creates both crop-specific and comprehensive field datasets.
#'
#' @param inputshape sf object Complete processed land use data
#' @param config list Configuration object  
#' @param params list Parameter object
#' @param suffix character Scenario identifier
#' @param data list All loaded parameter datasets
#' @details
#' Creates three shapefiles:
#' \itemize{
#'   \item fields_input: Only pollinator-dependent crops (target_ncs)
#'   \item allinvekos_fields_input: All INVEKOS agricultural fields
#'   \item org_fields_input: All organic agricultural fields
#' }
#' 
#' Added attributes:
#' \itemize{
#'   \item half_sat: Half-saturation coefficient for pollinator effectiveness
#'   \item p_managed: Proportion of managed vs. wild pollinators
#' }
#' @examples
#' create_field_shapefiles(inputshape, config, params, "Org", data)
create_field_shapefiles <- function(inputshape, config, params, suffix, data) {
  message("Creating field shapefiles...")
  
  # Add pollinator parameters to all features
  inputshape_enhanced <- inputshape %>%
    left_join(data$half_sat %>% select(nc, half_sat), by = "nc") %>%
    left_join(data$p_managed %>% select(AGS, p_managed), by = "AGS") %>%
    select(-AGS)  # Remove AGS to avoid shapefile column limit issues
  
  # Create crop-specific shapefile (pollinator-dependent crops only)
  crops_shape <- inputshape_enhanced %>%
    filter(nc %in% config$target_ncs)
  
  message("  → Pollinator-dependent crops: ", nrow(crops_shape), " features")
  
  # Create INVEKOS shapefile (all agricultural fields)  
  invekos_shape <- inputshape_enhanced %>%
    filter(endsWith(nc, "INV"))
  
  message("  → All INVEKOS fields: ", nrow(invekos_shape), " features")
  
  # Create organic fields shapefile
  organic_shape <- inputshape_enhanced %>%
    filter(grepl("o", nc))
  
  message("  → All organic fields: ", nrow(organic_shape), " features")
  
  # Save shapefiles
  crops_file <- file.path(config$wdir, 
                          paste0("fields_input", config$region, 
                                 if(params$year == "base") "" else params$sim, 
                                 params$year, suffix, ".shp"))
  
  invekos_file <- file.path(config$wdir, 
                            paste0("allinvekos_fields_input", config$region, 
                                   if(params$year == "base") "" else params$sim, 
                                   params$year, suffix, ".shp"))
  
  organic_file <- file.path(config$wdir, 
                            paste0("allorganic_fields_input", config$region, 
                                   if(params$year == "base") "" else params$sim, 
                                   params$year, suffix, ".shp"))
  
  st_write(crops_shape, crops_file, append = FALSE, quiet = TRUE)
  st_write(invekos_shape, invekos_file, append = FALSE, quiet = TRUE)
  st_write(organic_shape, organic_file, append = FALSE, quiet = TRUE)
  
  message("  → Crop fields saved: ", basename(crops_file))
  message("  → All fields saved: ", basename(invekos_file))
  message("  → Organic fields saved: ", basename(organic_file))
  
  # Calculate and report area statistics
  crop_area_ha <- sum(st_area(crops_shape)) / 10000  # Convert m² to hectares
  total_area_ha <- sum(st_area(invekos_shape)) / 10000
  organic_area_ha <- sum(st_area(organic_shape)) / 10000
  
  message("  → Pollinator-dependent crop area: ", round(crop_area_ha, 1), " ha")
  message("  → Total agricultural area: ", round(total_area_ha, 1), " ha")
  message("  → Total organic area: ", round(organic_area_ha, 1), " ha")
  
  return(invekos_file)
}


# ---- JSON CONFIGURATION ----
#' Create JSON configuration file for INVEST model
#'
#' Generates JSON configuration files that can be used directly with
#' INVEST Command Line Interface or Python API for automated model runs.
#'
#' @param config list Configuration object
#' @param params list Parameter object  
#' @param suffix character Scenario identifier
#' @details
#' JSON structure follows INVEST 3.7.0 specification for pollination model.
#' Includes all required file paths and model parameters.
#' 
#' Output directory structure: workbench/folder/
#' @examples
#' create_json_config(config, params, "Org")

create_json_config <- function(config, params, suffix, invekos_file, raster_output) {
  message("Creating JSON configuration...")
  
  # ---- CREATE JSON FILE ----
  # Define relative file paths (relative to working directory)
  farm_vector_path <- basename(invekos_file)
  landcover_raster_path <- basename(raster_output)
  
  # Absolute paths for parameter tables
  guild_table_path <- file.path(params$workbench, "guild_table_1_guild.csv")
  landcover_biophysical_table_path <- file.path(params$workbench,
                                                paste0("biophisical_table_", suffix,
                                                       ifelse(params$SNH_id == "", "", 
                                                              paste0("_", params$SNH_id)), ".csv"))
  results_suffix <- paste0(if(params$year == "base") "base" else params$sim, "_all_", suffix)  
  
  # Create JSON list
  json_data <- list(
    args = list(
      farm_vector_path = farm_vector_path,
      guild_table_path = guild_table_path,
      landcover_biophysical_table_path = landcover_biophysical_table_path,
      landcover_raster_path = landcover_raster_path,
      results_suffix = results_suffix
    ),
    invest_version = "3.7.0",
    model_name = "natcap.invest.pollination"
  )
  
  # Define output directory and file path
  json_output_file <- file.path(params$workbench, params$folder, 
                                paste0("pollination_", 
                                       if(params$year == "base") params$year else params$sim, 
                                       suffix, params$SNH_id, ".json"))
  
  
  # Write JSON
  write_json(json_data, path = json_output_file, pretty = TRUE, auto_unbox = TRUE)
  
  message("JSON configuration file written to:", json_output_file, "\n")
  
  # Validate that referenced files exist
  file_paths <- unlist(json_data$args)
  relative_paths <- c(farm_vector_path, landcover_raster_path)
  absolute_paths <- c(guild_table_path, landcover_biophysical_table_path)
  
  # Check relative paths (in working directory)
  for (path in relative_paths) {
    full_path <- file.path(config$wdir, path)
    if (!file.exists(full_path)) {
      warning("Referenced file does not exist: ", full_path)
    }
  }
  
  # Check absolute paths
  for (path in absolute_paths) {
    if (!file.exists(path)) {
      warning("Referenced file does not exist: ", path)
    }
  }
}
# ---- MAIN EXECUTION FUNCTION ----
#' Main execution function
#'
#' Orchestrates the complete workflow for INVEST input data preparation.
#' Handles multiple scenarios and provides comprehensive progress reporting.
#'
#' @return list Named list of processed shapefiles for each scenario
#' @details
#' Execution workflow:
#' \enumerate{
#'   \item Parse and validate parameters
#'   \item Set up configuration and load data
#'   \item Process spatial data intersection  
#'   \item Run scenario processing for each requested scenario
#'   \item Generate summary statistics and completion report
#' }
#' 
#' Scenarios processed:
#' \itemize{
#'   \item "Org": Baseline organic farming scenario
#'   \item "NoOrg": No organic farming scenario (if run_noorg = TRUE)
#'   \item "AllOrg": All organic farming scenario (if run_allorg = TRUE)  
#' }
#' @examples
#' # For script execution:
#' results <- main()
#' 
#' # For interactive use:
#' source("script.R") 
#' results <- main()
main <- function() {
  message("################################################################################")
  message("#                    INVEST INPUT DATA PREPARATION                            #") 
  message("#                           Starting Process...                               #")
  message("################################################################################\n")
  
  # Initialize workflow
  params <- get_parameters()
  config <- setup_config(params)
  data <- load_base_data(config, params)
  
  # Process spatial data intersection
  poly <- process_palud_basemap(data$palud_raw, data$basemap)
  
  # Determine scenarios to process
  scenarios <- c("Org")  # Always process baseline scenario
  if (params$run_allorg) scenarios <- c(scenarios, "AllOrg")
  if (params$run_noorg) scenarios <- c(scenarios, "NoOrg")
  
  message("=== PROCESSING SCENARIOS ===")
  message("Scenarios to process: ", paste(scenarios, collapse = ", "))
  message("=============================\n")
  
  # Process each scenario
  results <- list()
  scenario_stats <- list()
  
  for (suffix in scenarios) {
    scenario_start <- Sys.time()
    scenario_result <- process_scenario(poly, suffix, config, params, data)
    results[[suffix]] <- scenario_result
    
    scenario_time <- round(difftime(Sys.time(), scenario_start, units = "mins"), 2) 
    
    scenario_stats[[suffix]] <- list(
      features = nrow(scenario_result$inputshape),
      area_ha = round(sum(st_area(scenario_result$inputshape)) / 10000, 1),
      processing_time = scenario_time,
      raster = scenario_result$raster,
      invekos = scenario_result$invekos,
      json = scenario_result$json
    )

  }
  
  # Generate completion report
  finish <- Sys.time()
  total_runtime <- round(difftime(finish, start, units = "mins"), 2)
  
  message("################################################################################")
  message("#                           PROCESSING COMPLETE                               #")
  message("################################################################################")
  message("📊 SUMMARY STATISTICS:")
  
  for (scenario in names(scenario_stats)) {
    stats <- scenario_stats[[scenario]]
    message(sprintf("  %s: %d features, %s ha, %s min", 
                    scenario, stats$features, stats$area_ha, stats$processing_time))
  }
  
  message("\n⏱  TIMING:")
  message("  Total runtime: ", total_runtime, " minutes")
  message("  Average per scenario: ", round(total_runtime / length(scenarios), 2), " minutes")
  
  message("\n📁 OUTPUT FILES CREATED:")
  message("\n📁 OUTPUT FILES CREATED:")
  for (scenario in names(scenario_stats)) {
    stats <- scenario_stats[[scenario]]
    message("  ", scenario, ":")
    message("    - Land cover raster:        ", stats$raster)
    message("    - All fields shapefile:     ", stats$invekos)
    if (!is.null(stats$json)) {
      message("    - JSON config:              ", stats$json)
    }
  }
  
  
  message("\n✅ All processing completed successfully!")
  message("   Output directory: ", config$wdir)
  message("################################################################################\n")
  
  return(results)
}

# ---- EXECUTION CONTROL ----
#' Script execution control
#' 
#' Automatically runs main() when script is executed from command line,
#' but allows manual control when sourced interactively.
if (!interactive()) {
  # Running as script - execute automatically
  tryCatch({
    results <- main()
  }, error = function(e) {
    message("❌ ERROR: ", e$message)
    message("📋 For help, check the documentation or run with --help")
    quit(status = 1)
  })
} else {
  # Interactive mode - provide instructions
  message("📖 INTERACTIVE MODE")
  message("   Script loaded successfully. Available functions:")
  message("   • main()                    - Run complete workflow")
  message("   • get_parameters()          - Get/set parameters") 
  message("   • load_base_data()          - Load input datasets")
  message("   • process_palud_basemap()   - Process spatial intersection")
  message("   • process_scenario()        - Process single scenario")
  message("   ")
  message("   To run: results <- main()")
  message("   To get help: ?main")
}


