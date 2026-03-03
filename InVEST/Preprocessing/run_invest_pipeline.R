# =============================================================================
# run_invest_pipeline.R
# =============================================================================
# Purpose: Runs the full PALUD-InVEST pipeline for specified scenarios
#          1. XLSXtoSHP conversion
#          2. InVEST input data preparation
#          3. InVEST pollination model
#          4. InVEST output preparation
# =============================================================================

# -----------------------------
# User Settings
# -----------------------------

DRY_RUN <- FALSE

# Folder names
folder <- "EE-v2"
palud_input <- "EE-v2"
invest_input <- "EE-v2"

# Base paths
base_paths <- list(
  palud_output = "C:/git/BEATLE/PALUD/PALUD_aggregated/Output",
  invest_input = "C:/git/BEATLE/InVEST/WORKBENCH/input",
  invest_results = "C:/git/BEATLE/InVEST/WORKBENCH/results",
  invest_exe = "C:/git/BEATLE/InVEST/WORKBENCH/InVEST 3.13.0 Workbench/resources/invest/invest.exe"
)

# R script paths
r_scripts <- list(
  xlsx_to_shp = "C:/git/BEATLE/PALUD_InVEST/R_skripts/1_XLSXtoSHP.R",
  invest_inputdata = "C:/git/BEATLE/PALUD_InVEST/R_skripts/2_INVEST_INPUTDATA_PALUDorg.R",
  invest_output = "C:/git/BEATLE/InVEST/scripts/4_INVEST_Output_Preparation.R"
)

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
# Define Scenarios
# -----------------------------

snh_scenarios <- generate_scenarios(
  sim = "SNH",
  float_sequences = list(
    seq(0.5, 0.85, by = 0.005)
  ),
  org_increase = 0.73
)

mix_scenarios <- generate_scenarios(
  sim = "MIX",
  float_sequences = list(
    seq(0.3, 0.5, by = 0.005)
  ),
  org_increase = 1.61
)

scenarios <- rbind(snh_scenarios, mix_scenarios)

# -----------------------------
# Helper Functions
# -----------------------------

log_message <- function(..., level = 0) {
  timestamp <- format(Sys.time(), "[%H:%M:%S]")
  indent <- strrep("  ", level)
  cat(timestamp, indent, paste0(...), "\n", sep = "")
}

run_command <- function(cmd, description, dry_run = FALSE) {
  log_message(description)
  log_message("Command: ", cmd, level = 1)
  
  if (dry_run) {
    log_message("[DRY RUN] Skipping execution", level = 1)
    return(0)
  }
  
  result <- system(cmd, intern = FALSE)
  
  if (result != 0) {
    log_message("WARNING: Command returned exit code ", result, level = 1)
  } else {
    log_message("Completed successfully", level = 1)
  }
  
  return(result)
}

run_rscript <- function(script_path, args, description, dry_run = FALSE) {
  # Build command with quoted arguments
  args_str <- paste(sprintf('"%s"', args), collapse = " ")
  cmd <- sprintf('Rscript "%s" %s', script_path, args_str)
  run_command(cmd, description, dry_run)
}

run_invest <- function(invest_exe, json_path, output_dir, description, dry_run = FALSE) {
  # Create output directory if needed
  if (!dry_run && !dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    log_message("Created directory: ", output_dir, level = 1)
  }
  
  cmd <- sprintf('"%s" -vvv run pollination -d "%s" -w "%s"',
                 invest_exe, json_path, output_dir)
  run_command(cmd, description, dry_run)
}

# -----------------------------
# Function: Run pipeline for one scenario
# -----------------------------

run_pipeline <- function(sc, folder, palud_input, base_paths, r_scripts, dry_run = FALSE) {
  
  sim <- sc$sim
  padded <- sc$padded
  
  # Construct variant name (e.g., "SNH_0808" or "MIX_0458")
  variant <- paste0(sim, "_", padded)
  
  cat("\n")
  cat(strrep("=", 60), "\n")
  log_message(sprintf("PROCESSING SCENARIO: %s", variant))
  cat(strrep("=", 60), "\n")
  
  # Define paths for this scenario
  palud_output_path <- file.path(base_paths$palud_output, palud_input, variant)
  invest_input_dir <- file.path(base_paths$invest_input, folder, sim)
  invest_output_dir <- file.path(base_paths$invest_results, folder, sim, variant)
  
  log_message("Paths:")
  log_message("PALUD output:   ", palud_output_path, level = 1)
  log_message("InVEST input:   ", invest_input_dir, level = 1)
  log_message("InVEST output:  ", invest_output_dir, level = 1)
  cat("\n")
  
  results <- list(
    xlsx_to_shp = NA,
    invest_inputdata = NA,
    invest_model = NA,
    invest_output = NA
  )
  
  # -------------------------
  # Step 1: Run 1_XLSXtoSHP.R
  # -------------------------
  cat(strrep("-", 40), "\n")
  log_message("STEP 1: XLSXtoSHP")
  cat(strrep("-", 40), "\n")
  
  # Arguments: year, sim, palud_output_path
  results$xlsx_to_shp <- run_rscript(
    script_path = r_scripts$xlsx_to_shp,
    args = c("2030", sim, palud_output_path),
    description = sprintf("Converting XLSX to SHP for %s", variant),
    dry_run = dry_run
  )
  cat("\n")
  
  # -------------------------
  # Step 2: Run 2_INVEST_INPUTDATA_PALUDorg.R
  # -------------------------
  cat(strrep("-", 40), "\n")
  log_message("STEP 2: InVEST Input Data Preparation")
  cat(strrep("-", 40), "\n")
  
  # Arguments: workbench, folder, year, sim, run_allorg, run_noorg, create_json, SNH_id
  results$invest_inputdata <- run_rscript(
    script_path = r_scripts$invest_inputdata,
    args = c(
      file.path(base_paths$invest_input, folder),  # workbench
      sim,                                          # folder (scenario subfolder)
      "2030",                                       # year
      sim,                                          # sim
      "FALSE",                                      # run_allorg
      "FALSE",                                      # run_noorg
      "TRUE",                                       # create_json
      ""                                            # SNH_id
    ),
    description = sprintf("Preparing InVEST input data for %s", variant),
    dry_run = dry_run
  )
  cat("\n")
  
  # -------------------------
  # Step 3: Run InVEST pollination model
  # -------------------------
  cat(strrep("-", 40), "\n")
  log_message("STEP 3: InVEST Pollination Model")
  cat(strrep("-", 40), "\n")
  
  json_path <- file.path(invest_input_dir, sprintf("pollination_%sOrg.json", sim))
  
  results$invest_model <- run_invest(
    invest_exe = base_paths$invest_exe,
    json_path = json_path,
    output_dir = invest_output_dir,
    description = sprintf("Running InVEST pollination for %s", variant),
    dry_run = dry_run
  )
  cat("\n")
  
  # -------------------------
  # Step 4: Run 4_INVEST_Output_Preparation.R
  # -------------------------
  cat(strrep("-", 40), "\n")
  log_message("STEP 4: InVEST Output Preparation")
  cat(strrep("-", 40), "\n")
  
  # Arguments: input_dir, output_dir, SCENARIO, allorg, noorg
  results$invest_output <- run_rscript(
    script_path = r_scripts$invest_output,
    args = c(
      invest_output_dir,   # input_dir
      invest_output_dir,   # output_dir
      sim,                 # SCENARIO
      "FALSE",             # allorg
      "FALSE"              # noorg
    ),
    description = sprintf("Processing InVEST output for %s", variant),
    dry_run = dry_run
  )
  
  # Return results
  return(results)
}

# =============================================================================
# Main Execution
# =============================================================================

cat("\n")
cat(strrep("=", 70), "\n")
cat("PALUD-InVEST PIPELINE\n")
cat(strrep("=", 70), "\n")

if (DRY_RUN) {
  cat(">>> DRY RUN MODE - No commands will be executed <<<\n")
}

cat("\n")
cat("Configuration:\n")
cat(sprintf("  Folder:          %s\n", folder))
cat(sprintf("  Total scenarios: %d\n", nrow(scenarios)))
cat("\n")

start_time <- Sys.time()
log_message("Starting pipeline")

# Track all results
all_results <- data.frame(
  scenario = character(),
  step1 = integer(),
  step2 = integer(),
  step3 = integer(),
  step4 = integer(),
  stringsAsFactors = FALSE
)

# -----------------------------
# Loop over all scenarios
# -----------------------------

for (i in seq_len(nrow(scenarios))) {
  sc <- scenarios[i, ]
  
  cat("\n")
  cat(strrep("#", 70), "\n")
  log_message(sprintf("SCENARIO %d/%d: %s_%s", i, nrow(scenarios), sc$sim, sc$padded))
  cat(strrep("#", 70), "\n")
  
  # Run the full pipeline for this scenario
  results <- run_pipeline(
    sc = sc,
    folder = folder,
    palud_input = palud_input,
    base_paths = base_paths,
    r_scripts = r_scripts,
    dry_run = DRY_RUN
  )
  
  # Record results
  all_results <- rbind(all_results, data.frame(
    scenario = paste0(sc$sim, "_", sc$padded),
    step1 = results$xlsx_to_shp,
    step2 = results$invest_inputdata,
    step3 = results$invest_model,
    step4 = results$invest_output,
    stringsAsFactors = FALSE
  ))
}

# =============================================================================
# Summary
# =============================================================================

end_time <- Sys.time()
duration <- end_time - start_time

cat("\n")
cat(strrep("=", 70), "\n")
cat("PIPELINE COMPLETE\n")
cat(strrep("=", 70), "\n\n")

if (DRY_RUN) {
  cat(">>> This was a DRY RUN - no commands were executed <<<\n\n")
}

cat("Timing:\n")
cat(sprintf("  Start:    %s\n", format(start_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  End:      %s\n", format(end_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("  Duration: %s\n", format(duration)))
cat("\n")

# Count successes/failures per step
cat("Results by step:\n")
for (step in c("step1", "step2", "step3", "step4")) {
  successes <- sum(all_results[[step]] == 0, na.rm = TRUE)
  failures <- sum(all_results[[step]] != 0, na.rm = TRUE)
  cat(sprintf("  %s: %d successful, %d failed\n", step, successes, failures))
}
cat("\n")

# List any failures
failed_scenarios <- all_results[
  all_results$step1 != 0 | all_results$step2 != 0 | 
    all_results$step3 != 0 | all_results$step4 != 0, 
]

if (nrow(failed_scenarios) > 0) {
  cat("Scenarios with errors:\n")
  print(failed_scenarios)
} else if (!DRY_RUN) {
  cat("All scenarios completed successfully!\n")
}

cat("\n")
cat(strrep("=", 70), "\n")