#!/usr/bin/env Rscript
# =============================================================================
# run_full_pipeline.R
# =============================================================================
# Purpose: Master script that runs the complete PALUD-InVEST pipeline:
#          1. run_MIX_SNH.R     - GAMS optimization for SNH and MIX scenarios
#          2. run_invest_pipeline.R - InVEST pollination model pipeline
#
# Features:
#   - Runs each script in a separate R session for isolation
#   - Captures stdout, stderr, and exit codes
#   - Provides detailed error report at the end
#   - Saves log files for each script
#   - Continues to next script even if one fails
#
# Usage:
#   Rscript run_full_pipeline.R
#   Rscript run_full_pipeline.R --dry-run
#
# Author: Saskia
# =============================================================================

# -----------------------------
# Configuration
# -----------------------------

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
DRY_RUN <- "--dry-run" %in% tolower(args)

# Script paths (modify these to match your setup)
SCRIPTS <- list(

gams_scenarios = list(
    name = "GAMS Scenarios (SNH/MIX)",
    path = "C:/git/BEATLE/PALUD/PALUD_aggregated/Model/run_MIX_SNH.R",
    description = "Runs GAMS optimization for SNH and MIX scenarios"
  ),
  invest_pipeline = list(
    name = "InVEST Pipeline",
    path = "C:/git/BEATLE/PALUD_InVEST/R_skripts/run_invest_pipeline.R",
    description = "Runs the full PALUD-InVEST pipeline (XLSXtoSHP, InVEST input, model, output)"
  )
)

# Output directory for logs
LOG_DIR <- "C:/git/BEATLE/PALUD_InVEST/log"

# -----------------------------
# Helper Functions
# -----------------------------

#' Print a formatted header
print_header <- function(text, char = "=", width = 70) {
  cat("\n")
  cat(strrep(char, width), "\n")
  cat(text, "\n")
  cat(strrep(char, width), "\n")
}

#' Print a formatted sub-header
print_subheader <- function(text, char = "-", width = 50) {
  cat(strrep(char, width), "\n")
  cat(text, "\n")
  cat(strrep(char, width), "\n")
}

#' Log message with timestamp
log_msg <- function(..., level = 0) {
  timestamp <- format(Sys.time(), "[%Y-%m-%d %H:%M:%S]")
  indent <- strrep("  ", level)
  message(timestamp, " ", indent, paste0(...))
}

#' Run an R script in a separate process with full output capture
#' 
#' @param script_path Path to the R script
#' @param script_name Name for logging purposes
#' @param log_file Path to save combined output
#' @param dry_run If TRUE, only simulate execution
#' @return List with exit_code, stdout, stderr, duration, and error details
run_script_isolated <- function(script_path, script_name, log_file, dry_run = FALSE) {
  
  log_msg("Starting: ", script_name)
  log_msg("Script: ", script_path, level = 1)
  log_msg("Log file: ", log_file, level = 1)
  
  # Validate script exists
  if (!file.exists(script_path)) {
    log_msg("ERROR: Script not found!", level = 1)
    return(list(
      exit_code = -1,
      stdout = "",
      stderr = paste("Script not found:", script_path),
      duration = 0,
      success = FALSE,
      error_type = "FILE_NOT_FOUND",
      error_details = paste("The script does not exist:", script_path)
    ))
  }
  
  if (dry_run) {
    log_msg("[DRY RUN] Would execute script", level = 1)
    return(list(
      exit_code = 0,
      stdout = "[DRY RUN] Script not executed",
      stderr = "",
      duration = 0,
      success = TRUE,
      error_type = NA,
      error_details = NA
    ))
  }
  
  start_time <- Sys.time()
  
  # Run the script in a separate R process
  # Using system2 for better control over stdout/stderr
  tryCatch({
    
    # Create temporary files for stdout and stderr
    stdout_file <- tempfile(pattern = "stdout_", fileext = ".txt")
    stderr_file <- tempfile(pattern = "stderr_", fileext = ".txt")
    
    # Build the command
    # Note: We change to the script's directory before running
    script_dir <- dirname(script_path)
    script_basename <- basename(script_path)
    
    # Run Rscript with working directory set to script location
    exit_code <- system2(
      command = "Rscript",
      args = c(
        "--vanilla",  # Don't load/save workspace
        shQuote(script_path)
      ),
      stdout = stdout_file,
      stderr = stderr_file,
      wait = TRUE
    )
    
    # Read captured output
    stdout_content <- if (file.exists(stdout_file)) {
      paste(readLines(stdout_file, warn = FALSE), collapse = "\n")
    } else ""
    
    stderr_content <- if (file.exists(stderr_file)) {
      paste(readLines(stderr_file, warn = FALSE), collapse = "\n")
    } else ""
    
    # Clean up temp files
    unlink(c(stdout_file, stderr_file))
    
    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    # Save combined log
    log_content <- paste0(
      "=== SCRIPT EXECUTION LOG ===\n",
      "Script: ", script_path, "\n",
      "Started: ", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n",
      "Finished: ", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n",
      "Duration: ", round(duration, 2), " seconds\n",
      "Exit code: ", exit_code, "\n",
      strrep("=", 50), "\n\n",
      "=== STDOUT ===\n",
      stdout_content, "\n\n",
      "=== STDERR ===\n",
      stderr_content, "\n"
    )
    
    # Ensure log directory exists
    log_dir <- dirname(log_file)
    if (!dir.exists(log_dir)) {
      dir.create(log_dir, recursive = TRUE)
    }
    writeLines(log_content, log_file)
    
    # Determine error type if failed
    error_type <- NA
    error_details <- NA
    
    if (exit_code != 0) {
      # Try to identify the error type from stderr
      if (grepl("cannot open|not found|does not exist", stderr_content, ignore.case = TRUE)) {
        error_type <- "FILE_ERROR"
        error_details <- "File or directory not found"
      } else if (grepl("error in|fatal error", stderr_content, ignore.case = TRUE)) {
        error_type <- "RUNTIME_ERROR"
        # Extract the error message
        error_lines <- strsplit(stderr_content, "\n")[[1]]
        error_idx <- grep("error", error_lines, ignore.case = TRUE)
        if (length(error_idx) > 0) {
          error_details <- paste(error_lines[error_idx], collapse = "; ")
        } else {
          error_details <- "Unknown runtime error"
        }
      } else if (grepl("gams|exit code", stderr_content, ignore.case = TRUE)) {
        error_type <- "GAMS_ERROR"
        error_details <- "GAMS returned non-zero exit code"
      } else {
        error_type <- "UNKNOWN_ERROR"
        error_details <- substr(stderr_content, 1, 500)  # First 500 chars
      }
    }
    
    log_msg("Completed with exit code: ", exit_code, level = 1)
    log_msg("Duration: ", round(duration, 2), " seconds", level = 1)
    
    return(list(
      exit_code = exit_code,
      stdout = stdout_content,
      stderr = stderr_content,
      duration = duration,
      success = (exit_code == 0),
      error_type = error_type,
      error_details = error_details
    ))
    
  }, error = function(e) {
    end_time <- Sys.time()
    duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    log_msg("EXCEPTION: ", e$message, level = 1)
    
    return(list(
      exit_code = -99,
      stdout = "",
      stderr = e$message,
      duration = duration,
      success = FALSE,
      error_type = "R_EXCEPTION",
      error_details = e$message
    ))
  })
}

#' Generate detailed error report
generate_error_report <- function(results, log_dir) {
  
  report_lines <- c(
    strrep("=", 70),
    "DETAILED ERROR REPORT",
    strrep("=", 70),
    "",
    sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    sprintf("Log directory: %s", log_dir),
    ""
  )
  
  # Summary table
  report_lines <- c(report_lines,
    strrep("-", 70),
    "SUMMARY",
    strrep("-", 70),
    sprintf("%-30s %-10s %-15s %s", "Script", "Status", "Duration", "Error Type"),
    strrep("-", 70)
  )
  
  for (name in names(results)) {
    r <- results[[name]]
    status <- if (r$success) "SUCCESS" else "FAILED"
    duration <- sprintf("%.1f sec", r$duration)
    error_type <- if (is.na(r$error_type)) "-" else r$error_type
    
    report_lines <- c(report_lines,
      sprintf("%-30s %-10s %-15s %s", name, status, duration, error_type)
    )
  }
  
  report_lines <- c(report_lines, "")
  
  # Detailed error information for failed scripts
  failed <- names(results)[sapply(results, function(x) !x$success)]
  
  if (length(failed) > 0) {
    report_lines <- c(report_lines,
      strrep("=", 70),
      "FAILED SCRIPTS - DETAILED INFORMATION",
      strrep("=", 70)
    )
    
    for (name in failed) {
      r <- results[[name]]
      
      report_lines <- c(report_lines,
        "",
        strrep("-", 50),
        sprintf("SCRIPT: %s", name),
        strrep("-", 50),
        sprintf("Exit code: %d", r$exit_code),
        sprintf("Error type: %s", r$error_type),
        sprintf("Error details: %s", r$error_details),
        "",
        "Last 30 lines of STDERR:",
        strrep("-", 30)
      )
      
      # Add last 30 lines of stderr
      stderr_lines <- strsplit(r$stderr, "\n")[[1]]
      n_lines <- length(stderr_lines)
      if (n_lines > 30) {
        stderr_lines <- c("... (truncated) ...", stderr_lines[(n_lines - 29):n_lines])
      }
      report_lines <- c(report_lines, stderr_lines)
    }
  } else {
    report_lines <- c(report_lines,
      strrep("=", 70),
      "ALL SCRIPTS COMPLETED SUCCESSFULLY",
      strrep("=", 70)
    )
  }
  
  # Log file locations
  report_lines <- c(report_lines,
    "",
    strrep("-", 70),
    "LOG FILE LOCATIONS",
    strrep("-", 70)
  )
  
  for (name in names(results)) {
    log_file <- file.path(log_dir, paste0(gsub(" ", "_", name), ".log"))
    report_lines <- c(report_lines,
      sprintf("  %s:", name),
      sprintf("    %s", log_file)
    )
  }
  
  report_lines <- c(report_lines, "", strrep("=", 70))
  
  return(paste(report_lines, collapse = "\n"))
}

# =============================================================================
# Main Execution
# =============================================================================

print_header("FULL PIPELINE RUNNER")

if (DRY_RUN) {
  cat("\n>>> DRY RUN MODE - Scripts will not be executed <<<\n")
}

cat("\n")
cat("Configuration:\n")
cat(sprintf("  Log directory: %s\n", LOG_DIR))
cat(sprintf("  Scripts to run: %d\n", length(SCRIPTS)))
cat("\n")

# List scripts
cat("Scripts:\n")
for (i in seq_along(SCRIPTS)) {
  s <- SCRIPTS[[i]]
  cat(sprintf("  %d. %s\n", i, s$name))
  cat(sprintf("     Path: %s\n", s$path))
  cat(sprintf("     %s\n", s$description))
}
cat("\n")

# Ensure log directory exists
if (!dir.exists(LOG_DIR)) {
  dir.create(LOG_DIR, recursive = TRUE)
  log_msg("Created log directory: ", LOG_DIR)
}

# Track results
results <- list()
pipeline_start <- Sys.time()

log_msg("Starting full pipeline")
cat("\n")

# -----------------------------
# Run each script
# -----------------------------

for (i in seq_along(SCRIPTS)) {
  s <- SCRIPTS[[i]]
  
  print_header(sprintf("STEP %d/%d: %s", i, length(SCRIPTS), s$name), char = "#")
  cat(s$description, "\n\n")
  
  # Generate log file path with timestamp
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  log_file <- file.path(LOG_DIR, sprintf("%02d_%s_%s.log", 
                                          i, 
                                          gsub("[^a-zA-Z0-9]", "_", s$name),
                                          timestamp))
  
  # Run the script
  result <- run_script_isolated(
    script_path = s$path,
    script_name = s$name,
    log_file = log_file,
    dry_run = DRY_RUN
  )
  
  results[[s$name]] <- result
  
  # Print immediate feedback
  if (result$success) {
    log_msg("✓ ", s$name, " completed successfully")
  } else {
    log_msg("✗ ", s$name, " FAILED (exit code: ", result$exit_code, ")")
    log_msg("  Error type: ", result$error_type, level = 1)
    log_msg("  Details: ", substr(result$error_details, 1, 100), level = 1)
  }
  
  cat("\n")
}

# =============================================================================
# Final Summary
# =============================================================================

pipeline_end <- Sys.time()
pipeline_duration <- difftime(pipeline_end, pipeline_start, units = "mins")

print_header("PIPELINE COMPLETE")

# Timing
cat("\nTiming:\n")
cat(sprintf("  Started:  %s\n", format(pipeline_start, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Finished: %s\n", format(pipeline_end, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Duration: %.1f minutes\n", as.numeric(pipeline_duration)))

# Quick summary
cat("\nResults Summary:\n")
n_success <- sum(sapply(results, function(x) x$success))
n_failed <- length(results) - n_success
cat(sprintf("  Successful: %d / %d\n", n_success, length(results)))
cat(sprintf("  Failed:     %d / %d\n", n_failed, length(results)))

# Generate and print detailed error report
error_report <- generate_error_report(results, LOG_DIR)
cat("\n")
cat(error_report)

# Save error report to file
report_file <- file.path(LOG_DIR, sprintf("pipeline_report_%s.txt", 
                                           format(pipeline_start, "%Y%m%d_%H%M%S")))
writeLines(error_report, report_file)
cat("\n")
log_msg("Report saved to: ", report_file)

# Exit with appropriate code
if (n_failed > 0) {
  cat("\n")
  cat(strrep("!", 70), "\n")
  cat("WARNING: Some scripts failed. Check the error report above.\n")
  cat(strrep("!", 70), "\n")
  quit(status = 1, save = "no")
} else {
  cat("\n")
  cat("All scripts completed successfully!\n")
  quit(status = 0, save = "no")
}
