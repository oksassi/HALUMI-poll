# =============================================================================
# run_gams_scenarios.R
# =============================================================================
# Purpose: Runs GAMS optimization and simulation for SNH and MIX scenarios
#          with varying parameter values for sensitivity analysis.
#
# Workflow per scenario:
#   1. Model_optimisation.gms - optimizes land use allocation
#   2. SIM.gms - runs simulation and exports results to GDX
#
# Author: Saskia
# Last modified: 2026-01-27
# =============================================================================

# -----------------------------
# User Settings
# -----------------------------

# Set to TRUE to only print commands without executing GAMS
# Useful for checking parameter combinations before a long batch run
DRY_RUN <- FALSE

# Set working directory to script location (works in RStudio)
# Alternative: set manually with setwd("C:/git/BEATLE/PALUD/PALUD_aggregated")
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Output folder name (subfolder within Output/)
folder <- "EE-v2"

# Base path for GDX output files
base_output <- "C:/git/BEATLE/PALUD/PALUD_aggregated/Output"

# -----------------------------
# Function: generate_scenarios
# -----------------------------
# Creates a data frame of scenario parameters from one or more numeric sequences.
#
# Arguments:
#   sim             - Scenario name (e.g., "SNH" or "MIX")
#   float_sequences - List of numeric vectors (e.g., list(seq(0.4, 0.5, 0.005)))
#                     These are combined and deduplicated automatically
#   org_increase    - Value for org_increase_upper and org_increase_lower parameters
#
# Returns:
#   Data frame with columns: sim, padded, floatVal, org_increase

generate_scenarios <- function(sim, float_sequences, org_increase) {
  
  # Combine all sequences into one vector
  # unlist() flattens the list, unique() removes duplicates, sort() orders them
  floatVals <- unique(sort(unlist(float_sequences)))
  
  # Create padded string values for folder/file naming
  # Example: 0.405 -> "0405", 0.80 -> "0800"
  # round() handles floating point precision issues (e.g., 0.1 + 0.2 != 0.3)
  padded <- sprintf("%04d", round(floatVals * 1000))
  
  # Return as data frame for easy iteration
  data.frame(
    sim = sim,
    padded = padded,
    floatVal = floatVals,
    org_increase = org_increase,
    stringsAsFactors = FALSE
  )
}

# -----------------------------
# Define Scenario Parameter Ranges
# -----------------------------

# SNH (Semi-Natural Habitat) scenarios:
#   - Coarse grid: 0.70 to 0.85 in steps of 0.005 (31 values)
#   - Fine grid:   0.80 to 0.82 in steps of 0.001 (21 values)
#   - After deduplication: ~41 unique values
#   - org_increase fixed at 0.73
snh_scenarios <- generate_scenarios(
  sim = "SNH",
  float_sequences = list(
 #   seq(0.7, 0.85, by = 0.005),
  #  seq(0.5, 0.85, by = 0.005)
    0.777
  ),
  org_increase = 0.73
)

# MIX scenarios:
#   - Coarse grid: 0.40 to 0.50 in steps of 0.005 (21 values)
#   - Fine grid:   0.45 to 0.47 in steps of 0.001 (21 values)
#   - After deduplication: ~31 unique values
#   - org_increase fixed at 1.62
mix_scenarios <- generate_scenarios(
  sim = "MIX",
  float_sequences = list(
#    seq(0.4, 0.5, by = 0.005),
#    seq(0.3, 0.5, by = 0.005)
    0.413
  ),
  org_increase = 1.61
)

# Combine all scenarios into one data frame
# rbind() stacks data frames vertically (row bind)
scenarios <- rbind(snh_scenarios, mix_scenarios)

# -----------------------------
# Function: log_message
# -----------------------------
# Prints a timestamped message to the console.
# Helps track progress and timing during long batch runs.
#
# Arguments:
#   ...   - Message components (passed to paste0)
#   level - Indentation level (0 = no indent, 1 = "  ", 2 = "    ", etc.)

log_message <- function(..., level = 0) {
  timestamp <- format(Sys.time(), "[%H:%M:%S]")
  indent <- strrep("
  ", level)
  cat(timestamp, indent, paste0(...), "\n", sep = "")
}

# -----------------------------
# Function: run_gams
# -----------------------------
# Executes a GAMS model file with specified arguments.
#
# Arguments:
#   gms_file - Name of the .gms file to run
#   args     - Character vector of command line arguments
#   dry_run  - If TRUE, only print the command without executing
#
# Returns:
#   Exit code from GAMS (0 = success), or 0 if dry_run is TRUE

run_gams <- function(gms_file, args, dry_run = FALSE) {
  
  # Construct the full command string
  cmd <- paste("gams", gms_file, paste(args, collapse = " "))
  
  if (dry_run) {
    # Dry run mode: just show what would be executed
    log_message("[DRY RUN] Would execute:", level = 1)
    log_message(cmd, level = 2)
    return(0)  
  } else {
    # Actually run GAMS
    log_message("Executing GAMS...", level = 1)
    log_message(cmd, level = 2)
    
    # system() runs the command and returns the exit code
    # intern = FALSE means output goes to console, not captured
    result <- system(cmd, intern = FALSE)
    
    # Check for errors (non-zero exit code)
    if (result != 0) {
      log_message("WARNING: GAMS returned exit code ", result, level = 1)
    } else {
      log_message("GAMS completed successfully", level = 1)
    }
    
    return(result)
  }
}

# =============================================================================
# Main Execution
# =============================================================================

# Print run configuration summary
cat("\n")
cat(strrep("=", 60), "\n")
cat("GAMS BATCH RUNNER\n")
cat(strrep("=", 60), "\n")

if (DRY_RUN) {
  cat(">>> DRY RUN MODE - No GAMS commands will be executed <<<\n")
}

cat("\n")
cat("Working directory:", getwd(), "\n")
cat("Output folder:    ", folder, "\n")
cat("Base output path: ", base_output, "\n")
cat("\n")

# Print scenario summary table
cat("Scenarios to run:\n")
cat(sprintf("  %-5s  %s\n", "Type", "Count"))
cat(sprintf("  %-5s  %s\n", "----", "-----"))
cat(sprintf("  %-5s  %d\n", "SNH", nrow(snh_scenarios)))
cat(sprintf("  %-5s  %d\n", "MIX", nrow(mix_scenarios)))
cat(sprintf("  %-5s  %d\n", "TOTAL", nrow(scenarios)))
cat("\n")

# Show parameter ranges for verification
cat("Parameter ranges:\n")
cat(sprintf("  SNH floatVal: %.3f to %.3f\n", min(snh_scenarios$floatVal), max(snh_scenarios$floatVal)))
cat(sprintf("  MIX floatVal: %.3f to %.3f\n", min(mix_scenarios$floatVal), max(mix_scenarios$floatVal)))
cat("\n")

cat(strrep("=", 60), "\n\n")

# Record start time for total runtime calculation
start_time <- Sys.time()
log_message("Starting batch run")
cat("\n")

# Track results for summary
results <- data.frame(
  scenario = character(),
  floatVal = numeric(),
  status = character(),
  stringsAsFactors = FALSE
)

# -----------------------------
# Main Loop: Iterate Over Scenarios
# -----------------------------

for (i in seq_len(nrow(scenarios))) {
  
  # Extract current scenario parameters
  sc <- scenarios[i, ]
  
  # Print scenario header
  cat(strrep("-", 60), "\n")
  log_message(sprintf("SCENARIO %d/%d: %s (floatVal = %.3f, padded = %s)", 
                      i, nrow(scenarios), sc$sim, sc$floatVal, sc$padded))
  cat(strrep("-", 60), "\n")
  
  # ----- Construct file paths -----
  
  # rVal: Save/restart file path for GAMS
  # Pattern: ./t/BW_opt_[sim]_[padded]
  rVal <- sprintf("./t/BW_opt_%s_%s", tolower(sc$sim), sc$padded)
  log_message("Restart file (r/s): ", rVal, level = 1)
  
  # gdxVal: Path to output GDX file
  # Pattern: [base_output]/[folder]/[SIM]_[padded].gdx
  gdxVal <- file.path(base_output, folder, paste0(sc$sim, "_", sc$padded, ".gdx"))
  log_message("GDX output file:    ", gdxVal, level = 1)
  
  # outdirVal: Directory for scenario outputs
  # Pattern: Output/[folder]/[SIM]_[padded]
  outdirVal <- file.path(base_output, folder, paste0(sc$sim, "_", sc$padded))
  log_message("Output directory:   ", outdirVal, level = 1)
  
  # ----- Create output directory if needed -----
  
  # ----- Create output directory if needed -----
  
  if (!dir.exists(outdirVal)) {
    # Create directory even in dry run mode to prepare folder structure
    dir.create(outdirVal, recursive = TRUE)
    log_message("Created directory: ", outdirVal, level = 1)
  } else {
    log_message("Directory already exists", level = 1)
  }
  
  cat("\n")
  
  # ----- Step 1: Run Model_optimisation.gms -----
  
  log_message("STEP 1: Running Model_optimisation.gms")
  
  # Build argument list for optimization model
  opt_args <- c(
    "r=./t/BW",                                         # Restart from base save file
    sprintf("s=%s", rVal),                              # Save state to scenario-specific file
    sprintf("--org_increase_upper=%s", sc$org_increase), # Upper bound for organic increase
    sprintf("--org_increase_lower=%s", sc$org_increase), # Lower bound for organic increase
    sprintf("--snh_increase=%s", sc$floatVal)            # SNH increase parameter (varies)
  )
  
  result1 <- run_gams("Model_optimisation.gms", opt_args, dry_run = DRY_RUN)
  
  cat("\n")
  
  # ----- Step 2: Run SIM.gms -----
  
  log_message("STEP 2: Running SIM.gms")
  
  # Build argument list for simulation model
  sim_args <- c(
    sprintf("--outdir=%s", outdirVal),  # Output directory for results
    sprintf("r=%s", rVal),              # Restart from optimization save file
    sprintf("GDX=%s", gdxVal),          # Path for GDX export
    sprintf("--SIM=%s", sc$sim)         # Scenario identifier
  )
  
  # MIX scenarios need an additional save file parameter
  # This preserves intermediate results for potential further analysis
  if (sc$sim == "MIX") {
    sVal <- sprintf("./t/BW_res_%s_%s", sc$sim, sc$padded)
    sim_args <- c(sim_args, sprintf("s=%s", sVal))
    log_message("(MIX scenario: adding save file ", sVal, ")", level = 1)
  }
  
  result2 <- run_gams("SIM.gms", sim_args, dry_run = DRY_RUN)
  
  # ----- Record result -----
  
  status <- ifelse(DRY_RUN, "dry_run", 
                   ifelse(result1 == 0 && result2 == 0, "success", "error"))
  
  results <- rbind(results, data.frame(
    scenario = paste0(sc$sim, "_", sc$padded),
    floatVal = sc$floatVal,
    status = status,
    stringsAsFactors = FALSE
  ))
  
  cat("\n")
}

# =============================================================================
# Runtime Summary
# =============================================================================

end_time <- Sys.time()
duration <- end_time - start_time

cat(strrep("=", 60), "\n")
cat("BATCH RUN COMPLETE\n")
cat(strrep("=", 60), "\n\n")

if (DRY_RUN) {
  cat(">>> This was a DRY RUN - no GAMS commands were executed <<<\n\n")
}

# Print timing information
cat("Timing:\n")
cat(sprintf("  Start:    %s\n", format(start_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  End:      %s\n", format(end_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Duration: %s\n", format(duration)))
cat("\n")

# Print results summary
cat("Results:\n")
cat(sprintf("  Total scenarios:  %d\n", nrow(results)))
cat(sprintf("  Successful:       %d\n", sum(results$status == "success")))
cat(sprintf("  Errors:           %d\n", sum(results$status == "error")))
cat(sprintf("  Dry run:          %d\n", sum(results$status == "dry_run")))
cat("\n")

# List any errors
if (any(results$status == "error")) {
  cat("Failed scenarios:\n")
  failed <- results[results$status == "error", ]
  for (j in seq_len(nrow(failed))) {
    cat(sprintf("  - %s (floatVal = %.3f)\n", failed$scenario[j], failed$floatVal[j]))
  }
  cat("\n")
}

cat(strrep("=", 60), "\n")
cat("To run for real, set DRY_RUN <- FALSE at the top of the script\n")
cat(strrep("=", 60), "\n")