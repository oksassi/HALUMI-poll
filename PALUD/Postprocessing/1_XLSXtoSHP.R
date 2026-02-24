################################################################################
# Name:   1_XLSXtoSHP.R                                                        #
# Author: Saskia Osterkamp                                                     #
# Date:   24.02.2026                                                           #
# This script translates the PALUD model output in excel format to spatial data#
# Assigns a code to each Kennung_PALUD.                                        #
# Input:  args[1]: The year that should be extracted from the PALUD output and #
#                  further be simulated with InVEST (usually "2030" but you may#
#                  want to explore other years or the base-year "base")        #
#         args[2]: The scenario as suffix (e.g., "OF", "BAU")                  #
#         args[3]: The filepath to the PALUD output file fields[suffix].XLSX   #
#         args[4]: (Optional) The file path to the original InVeKoS dataset to #
#                  match the plots.                                            #
#                  Defaults to PALUD/Input/InVeKoS_Hohenlohe_2021.shp          #
# Output: Shapefile with PALUD output, stored in the same folder               #
#         as the PALUD output file.                                            #
################################################################################

# --------------------------------
# --- RUN GAMS MODEL BEFORE!   ---
# --------------------------------
start <- Sys.time()

# ---- ERROR HANDLING ----
logmsg <- function(msg) {
  cat(paste0("[", Sys.time(), "] ", msg, "\n"))
}

handle_error <- function(e) {
  cat(paste0("❌ ERROR: ", e$message, "\n"))
  quit(save = "no", status = 1)
}


# ---- SET RSCRIPT ----
# For use in Rscipt only
# Read in parameters from command line

args <- commandArgs(trailingOnly = TRUE)
year <- args[1]
suffix <- args[2]
inputdir <- args[3]

# Set invekos file: use argument if provided, otherwise default
if (length(args) >= 4 && nchar(args[4]) > 0) {
  invekos_file <- args[4]
} else {
  invekos_file <- "C:/git/HALUMI_poll/PALUD/Input/InVeKoS_Hohenlohe_2021.shp"
  logmsg(paste("No InVeKoS file specified. Using default:", invekos_file))
}

# Print the parameters to check
cat("Running with:\n")
cat("year =", year, "\n")
cat("suffix =", suffix, "\n")
cat("inputdir =", inputdir, "\n")
cat("invekos_file =", invekos_file, "\n")


# ---- SET MANUALLY ----  
# year <- "base" # base
# suffix <- "base" # SNH
# inputdir <- "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/EE-v2/"

# ---- SET ----

# set model type
model_type <- "org"
#model_type <- ""

output_filename <- paste0("PALUD_shapefile_", suffix, year)

# ---- LOAD LIBRARIES ----

library(sf)
library(openxlsx)
library(readxl)
library(stringi)
library(dplyr)
library(mapview)

# ---- READ FILES ----

# ---- READ SHAPEFILE ----
logmsg("Reading shapefile...")
invekos_sf <- tryCatch({
  st_read(invekos_file)
}, error = handle_error)
logmsg("Shapefile loaded.")

# Read PALUD output file
logmsg("Reading PALUD output...")
df <- tryCatch({
  read.xlsx(file.path(inputdir, paste0("fields_", suffix, ".xlsx")))
}, error = handle_error)
logmsg("PALUD output file loaded.")

# ---- DATA CLEANING ----

print("START Data cleaning and merging.")
logmsg("Data cleaning...")

df <- df %>% subset(df$Year == year)
df <- df %>% dplyr::select(-Year)

sf2 <- invekos_sf %>% dplyr::select(-c(K_PALUD, KULTGRU, FAKT_CO, OEVF_CO))

# Add REGBEZ & REGBEZNR 
# Note: This approach is not generalizable!
# TODO: Lookup from AGS instead of hardcoded names
sf2$REGBEZ <- "Stuttgart"
sf2$REGBEZNR <- "DE11"


logmsg("Data cleaning successful.")


# ---- MERGE DATA BY Schlag_ID ----

logmsg("Merging files...")

# Delete the dots and convert to numeric
sf2$Schlag_ID <- gsub("\\.", "", sf2$SCHLAG_)

# Subset the rows where Schlag_ID matches any value in PALUD output
subset_sf <- sf2[sf2$Schlag_ID %in% df$Schlag_ID, ]

subset_sf <- subset_sf %>% dplyr::select(-"SCHLAG_")

df2 <- df %>% dplyr::select(-c(AGS))


sf_object2 <- tryCatch({
  sf_object2 <-  merge(x=subset_sf, y = df2, by = "Schlag_ID")
}, error = handle_error)
logmsg("Merging completed.")



# ---- MORE DATA CLEANING ----

sf_object2 <- sf_object2[, c(1, 4:7, 13,3, 2, 15:18, 11,9,10,19)]
colnames(sf_object2) <- c("Schlag_ID", "AGS", "NAME", "NUTS_CODE",  "NUTS_NAME",
                          "SOIL", "SIZE", "AREA", "REGBEZ", "REGBEZNR", "K_PALUD", "n", "FL_ART", "NC", 
                          "NUTZUNG", "geometry") 
st_geometry(sf_object2) <- "geometry"

if (interactive()) {
  mapview(sf_object2)
}


# ---- ASSIGN NC CODES ----


# Assign NC codes to each Kennung_PALUD 
# Attention when changing these codes! 
# They correspond to an entry in the biophysical table!
if(model_type == "org"){
  logmsg("Assign NC Codes...")
  sf_object2$NC <- as.character(sf_object2$NC)
  sf_object2 <- tryCatch({
    sf_object2 %>%
      mutate(NC = case_when(
        K_PALUD == "Erd" ~ "707",
        K_PALUD == "SO" ~ "320",
        K_PALUD == "B" ~ "591",
        K_PALUD == "BL" ~ "590",
        K_PALUD == "GE" ~ "610",
        K_PALUD == "Ha" ~ "143",
        K_PALUD == "KG" ~ "422",
        K_PALUD == "Ka" ~ "602",
        K_PALUD == "KL" ~ "210",
        K_PALUD == "KM" ~ "171",
        K_PALUD == "Rog" ~ "121",
        K_PALUD == "SG" ~ "132",
        K_PALUD == "SJ" ~ "330",
        K_PALUD == "SM" ~ "172",
        K_PALUD == "Som" ~ "116",
        K_PALUD == "WG" ~ "131",
        K_PALUD == "Win" ~ "112",
        K_PALUD == "WR" ~ "311",
        K_PALUD == "WW" ~ "115",
        K_PALUD == "SB" ~ "321",
        K_PALUD == "ZR" ~ "603",
        K_PALUD == "GSM" ~ "452",
        K_PALUD == "GHM" ~ "452",
        K_PALUD == "BG" ~ "592",
        K_PALUD == "oErd" ~ "707o",
        K_PALUD == "oSO" ~ "320o",
        K_PALUD == "oB" ~ "591o",
        K_PALUD == "oBL" ~ "590o",      
        K_PALUD == "oGE" ~ "610o",
        K_PALUD == "oHa" ~ "143o",
        K_PALUD == "oKG" ~ "422o",
        K_PALUD == "oKa" ~ "602o",
        K_PALUD == "oKL" ~ "210o",
        K_PALUD == "oKM" ~ "171o",
        K_PALUD == "oRog" ~ "121o",
        K_PALUD == "oSG" ~ "132o",
        K_PALUD == "oSJ" ~ "330o",
        K_PALUD == "oSM" ~ "172o",
        K_PALUD == "oSom" ~ "116o",
        K_PALUD == "oWG" ~ "131o",
        K_PALUD == "oWin" ~ "112o",
        K_PALUD == "oWR" ~ "311o",
        K_PALUD == "oWW" ~ "115o",
        K_PALUD == "oSB" ~ "321o",
        K_PALUD == "oZR" ~ "603o",
        K_PALUD == "oGSM" ~ "452o",
        K_PALUD == "oGHM" ~ "452o",
        K_PALUD == "oBG" ~ "592o",
        TRUE ~ "NA"  # Assign NA for any unmatched values
      ))
  }, error = handle_error)
  logmsg("NC codes assigned.")
}      
print("END data cleaning and merging")

# ---- SAVE SHAPEFILE ----

logmsg("Writing shapefile to inputdir...")
tryCatch({
  st_write(sf_object2, 
           paste0(inputdir, output_filename, ".shp"), 
           append = FALSE)
}, error = handle_error)
logmsg("Writing shapefile successful")

print("FINISH")
finish <- Sys.time()
finish-start

logmsg("✅ Script completed successfully.")
logmsg(paste("⏱ Total runtime:", round(difftime(Sys.time(), start, units = "mins"), 2), "minutes."))