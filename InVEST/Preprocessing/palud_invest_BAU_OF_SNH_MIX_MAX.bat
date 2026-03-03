setlocal enabledelayedexpansion

:: Store start time
for /f "delims=" %%a in ('powershell -command "Get-Date -Format o"') do set "start_time=%%a"

set SNH_variant=SNH_0777
set MIX_variant=MIX_0413
set palud_input=EE-v2
set invest_input=EE-v2
set folder=EE-v2
:: -----------------------------
:: Run 1_XLSXtoSHP.R
:: -----------------------------
set R_SCRIPT_PATH_1=C:\git\BEATLE\PALUD_InVEST\R_skripts\1_XLSXtoSHP.R


echo Running 1_XLSXtoSHP - RUN BAU
Rscript "%R_SCRIPT_PATH_1%" "2030" "BAU" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%palud_input%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN BAU failed. See R output for details.
     pause
)

echo Running 1_XLSXtoSHP - RUN OF
Rscript "%R_SCRIPT_PATH_1%" "2030" "OF" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%palud_input%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN OF failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN SNH
Rscript "%R_SCRIPT_PATH_1%" "2030" "SNH" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%palud_input%/%SNH_variant%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN SNH failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN MIX
Rscript "%R_SCRIPT_PATH_1%" "2030" "MIX" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%palud_input%/%MIX_variant%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN MIX failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN MAX
Rscript "%R_SCRIPT_PATH_1%" "2030" "MAX" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%palud_input%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN MAX failed. See R output for details.
    pause
)

:: -----------------------------
:: Run 2_INVEST_INPUTDATA_PALUDorg.R
:: -----------------------------
REM #' Command line parameters (in order):
REM #' \itemize{
REM #'   \item workbench: Base working directory path
REM #'   \item folder: Subdirectory name for scenario
REM #'   \item year: Target year for analysis (e.g., "2030")
REM #'   \item sim: Additional identifier for file naming
REM #'   \item run_allorg: Logical, whether to process AllOrg scenario
REM #'   \item run_noorg: Logical, whether to process NoOrg scenario  
REM #'   \item create_json: Logical, whether to create JSON config files
REM #'   \item SNH_id: Semi-natural habitat identifier
REM #' }

set R_SCRIPT_PATH_2=C:\git\BEATLE\PALUD_InVEST\R_skripts\2_INVEST_INPUTDATA_PALUDorg.R


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN BAU
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%invest_input%" "BAU" "2030" "BAU" "FALSE" "TRUE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN OF
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%invest_input%" "OF" "2030" "OF" "FALSE" "TRUE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN SNH
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%invest_input%/%SNH_variant%" "SNH" "2030" "SNH" "FALSE" "TRUE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN MIX
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%invest_input%/%MIX_variant%" "MIX" "2030" "MIX" "FALSE" "TRUE" "TRUE" ""



set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%invest_input%\SNH
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\SNH\%SNH_variant%

:: Run SNH
echo Running pollination_SNHNoOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_SNHNoOrg.json" -w "%OUTPUT_DIR%"   
echo.

set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%invest_input%\MIX
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\MIX\%MIX_variant%

:: Run MIX
echo Running pollination_MIXNoOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_MIXNoOrg.json" -w "%OUTPUT_DIR%"   
echo.

set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%invest_input%\MAX
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\MAX

:: Run MAX
echo Running pollination_MAXNoOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_MAXNoOrg.json" -w "%OUTPUT_DIR%"   
echo.

:: -----------------------------
:: Run 4_INVEST_Output_Preparation.R
:: -----------------------------
set R_SCRIPT_PATH_3=C:\git\BEATLE\InVEST\scripts\4_INVEST_Output_Preparation.R
 REM input_dir <- "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/SNH/snh_10" 
 REM output_dir <- "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/SNH/snh_10"
 REM SCENARIO <- "SNH"
 REM allorg <- TRUE
 REM noorg <- TRUE
 

:: Run BAU
echo Running 4_INVEST_Output_Preparation.R for BAU...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "BAU" "FALSE" "TRUE"

:: Run OF
echo Running 4_INVEST_Output_Preparation.R for OF...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "OF" "FALSE" "TRUE"

:: Run SNH
echo Running 4_INVEST_Output_Preparation.R for SNH...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/SNH/%SNH_variant%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/SNH/%SNH_variant%" "SNH" "FALSE" "TRUE"

:: Run MIX
echo Running 4_INVEST_Output_Preparation.R for MIX...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MIX/%MIX_variant%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MIX/%MIX_variant%" "MIX" "FALSE" "TRUE"

:: Run MAX
echo Running 4_INVEST_Output_Preparation.R for MAX...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "MAX" "FALSE" "TRUE"

:: -----------------------------
:: Calculate total runtime
:: -----------------------------

:: Store end time
for /f "delims=" %%a in ('powershell -command "Get-Date -Format o"') do set "end_time=%%a"

echo.
echo Start Time: %start_time%
echo End Time:   %end_time%

:: Calculate and display duration
powershell -command "$start=[datetime]::Parse('%start_time%'); $end=[datetime]::Parse('%end_time%'); $duration=$end - $start; Write-Host ('Total Runtime: {0:hh\:mm\:ss}' -f $duration)"

pause


