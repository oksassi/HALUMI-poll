# =============================================================================
# run_output_processing.R
# =============================================================================
# Purpose: Runs GAMS Output_processing.gms for each scenario to export
#          results from GDX files to Excel.
# =============================================================================

# -----------------------------
# User Settings
# -----------------------------

# Set to TRUE to only print commands without executing GAMS
DRY_RUN <- FALSE

# Set working directory to script location (works in RStudio)
#setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Output folder name (subfolder within Output/)
folder <- "EE-v2"

# Base path for GDX output files
base_output <- "C:/git/BEATLE/PALUD/PALUD_aggregated/Output"

# Path to the GAMS file
gams_file <- "C:/git/BEATLE/PALUD/PALUD_aggregated/Model/Output_processing.gms"

# -----------------------------
# Function: generate_scenarios
# -----------------------------

generate_scenarios <- function(sim, float_sequences, org_increase) {
  floatVals <- unique(sort(unlist(float_sequences)))
  padded <- sprintf("%04d", round(floatVals * 1000))
  
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

snh_scenarios <- generate_scenarios(
  sim = "SNH",
  float_sequences = list(
#    seq(0.5, 0.85, by = 0.005)
    0.777
  ),
  org_increase = 0.73
)

mix_scenarios <- generate_scenarios(
  sim = "MIX",
  float_sequences = list(
#    seq(0.3, 0.5, by = 0.005)
    0.413
  ),
  org_increase = 1.61
)

scenarios <- rbind(snh_scenarios, mix_scenarios)

# -----------------------------
# Helper functions
# -----------------------------

log_message <- function(..., level = 0) {
  timestamp <- format(Sys.time(), "[%H:%M:%S]")
  indent <- strrep("  ", level)
  cat(timestamp, indent, paste0(...), "\n", sep = "")
}

run_gams <- function(gms_file, args, dry_run = FALSE) {
  cmd <- paste("gams", gms_file, paste(args, collapse = " "))
  
  if (dry_run) {
    log_message("[DRY RUN] Would execute:", level = 1)
    log_message(cmd, level = 2)
    return(0)
  } else {
    log_message("Executing GAMS...", level = 1)
    log_message(cmd, level = 2)
    result <- system(cmd, intern = FALSE)
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

cat("\n")
cat(strrep("=", 60), "\n")
cat("GAMS OUTPUT PROCESSING\n")
cat(strrep("=", 60), "\n")

if (DRY_RUN) {
  cat(">>> DRY RUN MODE - No GAMS commands will be executed <<<\n")
}

cat("\n")
cat("GAMS file:        ", gams_file, "\n")
cat("Output folder:    ", folder, "\n")
cat("Total scenarios:  ", nrow(scenarios), "\n")
cat("\n")

start_time <- Sys.time()
log_message("Starting batch processing")
cat("\n")

# Track results
results <- data.frame(
  scenario = character(),
  status = character(),
  stringsAsFactors = FALSE
)

# -----------------------------
# Main Loop
# -----------------------------

for (i in seq_len(nrow(scenarios))) {
  sc <- scenarios[i, ]
  
  cat(strrep("-", 60), "\n")
  log_message(sprintf("SCENARIO %d/%d: %s_%s", i, nrow(scenarios), sc$sim, sc$padded))
  cat(strrep("-", 60), "\n")
  
  # Construct output directory name (relative path for GAMS)
  outdir <- file.path("Output", folder, paste0(sc$sim, "_", sc$padded))
  log_message("Output directory: ", outdir, level = 1)
  
  # Build GAMS arguments
  # Pass parameters using --parameter=value syntax
  gams_args <- c(
    sprintf("--SIM=%s", sc$sim),
    sprintf("--padded=%s", sc$padded),
    sprintf("--folder=%s", folder)
  )
  
  # Run GAMS
  result <- run_gams(gams_file, gams_args, dry_run = DRY_RUN)
  
  # Record result
  status <- ifelse(DRY_RUN, "dry_run", ifelse(result == 0, "success", "error"))
  results <- rbind(results, data.frame(
    scenario = paste0(sc$sim, "_", sc$padded),
    status = status,
    stringsAsFactors = FALSE
  ))
  
  cat("\n")
}

# =============================================================================
# Summary
# =============================================================================

end_time <- Sys.time()
duration <- end_time - start_time

cat(strrep("=", 60), "\n")
cat("BATCH PROCESSING COMPLETE\n")
cat(strrep("=", 60), "\n\n")

if (DRY_RUN) {
  cat(">>> This was a DRY RUN - no GAMS commands were executed <<<\n\n")
}

cat("Timing:\n")
cat(sprintf("  Start:    %s\n", format(start_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  End:      %s\n", format(end_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Duration: %s\n", format(duration)))
cat("\n")

cat("Results:\n")
cat(sprintf("  Total:      %d\n", nrow(results)))
cat(sprintf("  Successful: %d\n", sum(results$status == "success")))
cat(sprintf("  Errors:     %d\n", sum(results$status == "error")))
cat("\n")

if (any(results$status == "error")) {
  cat("Failed scenarios:\n")
  failed <- results[results$status == "error", ]
  for (j in seq_len(nrow(failed))) {
    cat(sprintf("  - %s\n", failed$scenario[j]))
  }
}
