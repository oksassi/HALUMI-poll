setlocal enabledelayedexpansion

:: Store start time
for /f "delims=" %%a in ('powershell -command "Get-Date -Format o"') do set "start_time=%%a"

set folder=sensitivity_analysis/%1/10plus
set folder_PALUD=sensitivity_analysis/null

:: -----------------------------
:: Run 1_XLSXtoSHP.R
:: -----------------------------
set R_SCRIPT_PATH_1=C:\git\BEATLE\PALUD_InVEST\R_skripts\1_XLSXtoSHP.R


echo Running 1_XLSXtoSHP - RUN BAU
Rscript "%R_SCRIPT_PATH_1%" "2030" "BAU" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN BAU failed. See R output for details.
     pause
)

echo Running 1_XLSXtoSHP - RUN OF
Rscript "%R_SCRIPT_PATH_1%" "2030" "OF" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN OF failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN 4
Rscript "%R_SCRIPT_PATH_1%" "2030" "MAX" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN 4 failed. See R output for details.
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
REM #'   \item sens_id: ID for sensitivity analysis (e.g., "%1")
REM #' }

set R_SCRIPT_PATH_2=C:\git\BEATLE\PALUD_InVEST\R_skripts\2_INVEST_INPUTDATA_PALUDorg.R


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN BAU
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "BAU" "2030" "BAU" "FALSE" "FALSE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN OF
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "OF" "2030" "OF" "FALSE" "FALSE" "TRUE" ""


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN 4 
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "MAX" "2030" "MAX" "FALSE" "FALSE" "TRUE" ""


:: -----------------------------
:: Run InVEST
:: -----------------------------

:: Set paths
set INVEST_EXE="C:\git\BEATLE\InVEST\WORKBENCH\InVEST 3.13.0 Workbench\resources\invest\invest.exe"


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\BAU
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\BAU

:: Run BAU
echo Running pollination_BAUOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_BAUOrg.json" -w "%OUTPUT_DIR%"
echo.

set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\OF
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\OF

:: Run OF
echo Running pollination_OFOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_OFOrg.json" -w "%OUTPUT_DIR%"
echo.


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\MAX
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\MAX

:: Run MAX
echo Running pollination_MAXOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_MAXOrg.json" -w "%OUTPUT_DIR%"   
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
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "BAU" "FALSE" "FALSE"

:: Run OF
echo Running 4_INVEST_Output_Preparation.R for OF...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "OF" "FALSE" "FALSE"

:: Run MAX
echo Running INVEST_Output_Preparation...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "MAX" "FALSE" "FALSE"








:: -----------------------------
:: Sensitivity analysis 10minus
:: -----------------------------

set folder=sensitivity_analysis/%1/10minus
set folder_PALUD=sensitivity_analysis/null

:: -----------------------------
:: Run 1_XLSXtoSHP.R
:: -----------------------------
set R_SCRIPT_PATH_1=C:\git\BEATLE\PALUD_InVEST\R_skripts\1_XLSXtoSHP.R


echo Running 1_XLSXtoSHP - RUN BAU
Rscript "%R_SCRIPT_PATH_1%" "2030" "BAU" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN BAU failed. See R output for details.
     pause
)

echo Running 1_XLSXtoSHP - RUN OF
Rscript "%R_SCRIPT_PATH_1%" "2030" "OF" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN OF failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN 4
Rscript "%R_SCRIPT_PATH_1%" "2030" "MAX" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN 4 failed. See R output for details.
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
REM #'   \item sens_id: ID for sensitivity analysis (e.g., "%1")
REM #' }

set R_SCRIPT_PATH_2=C:\git\BEATLE\PALUD_InVEST\R_skripts\2_INVEST_INPUTDATA_PALUDorg.R


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN BAU
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "BAU" "2030" "BAU" "FALSE" "FALSE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN OF
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "OF" "2030" "OF" "FALSE" "FALSE" "TRUE" ""


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN 4 
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "MAX" "2030" "MAX" "FALSE" "FALSE" "TRUE" ""


:: -----------------------------
:: Run InVEST
:: -----------------------------

:: Set paths
set INVEST_EXE="C:\git\BEATLE\InVEST\WORKBENCH\InVEST 3.13.0 Workbench\resources\invest\invest.exe"


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\BAU
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\BAU

:: Run BAU
echo Running pollination_BAUOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_BAUOrg.json" -w "%OUTPUT_DIR%"
echo.

set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\OF
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\OF

:: Run OF
echo Running pollination_OFOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_OFOrg.json" -w "%OUTPUT_DIR%"
echo.


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\MAX
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\MAX

:: Run MAX
echo Running pollination_MAXOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_MAXOrg.json" -w "%OUTPUT_DIR%"   
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
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "BAU" "FALSE" "FALSE"

:: Run OF
echo Running 4_INVEST_Output_Preparation.R for OF...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "OF" "FALSE" "FALSE"

:: Run MAX
echo Running INVEST_Output_Preparation...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "MAX" "FALSE" "FALSE"





:: -----------------------------
:: Sensitivity analysis 50plus
:: -----------------------------

set folder=sensitivity_analysis/%1/50plus
set folder_PALUD=sensitivity_analysis/null

:: -----------------------------
:: Run 1_XLSXtoSHP.R
:: -----------------------------
set R_SCRIPT_PATH_1=C:\git\BEATLE\PALUD_InVEST\R_skripts\1_XLSXtoSHP.R


echo Running 1_XLSXtoSHP - RUN BAU
Rscript "%R_SCRIPT_PATH_1%" "2030" "BAU" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN BAU failed. See R output for details.
     pause
)

echo Running 1_XLSXtoSHP - RUN OF
Rscript "%R_SCRIPT_PATH_1%" "2030" "OF" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN OF failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN 4
Rscript "%R_SCRIPT_PATH_1%" "2030" "MAX" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN 4 failed. See R output for details.
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
REM #'   \item sens_id: ID for sensitivity analysis (e.g., "%1")
REM #' }

set R_SCRIPT_PATH_2=C:\git\BEATLE\PALUD_InVEST\R_skripts\2_INVEST_INPUTDATA_PALUDorg.R


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN BAU
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "BAU" "2030" "BAU" "FALSE" "FALSE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN OF
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "OF" "2030" "OF" "FALSE" "FALSE" "TRUE" ""


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN 4 
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "MAX" "2030" "MAX" "FALSE" "FALSE" "TRUE" ""


:: -----------------------------
:: Run InVEST
:: -----------------------------

:: Set paths
set INVEST_EXE="C:\git\BEATLE\InVEST\WORKBENCH\InVEST 3.13.0 Workbench\resources\invest\invest.exe"


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\BAU
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\BAU

:: Run BAU
echo Running pollination_BAUOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_BAUOrg.json" -w "%OUTPUT_DIR%"
echo.

set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\OF
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\OF

:: Run OF
echo Running pollination_OFOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_OFOrg.json" -w "%OUTPUT_DIR%"
echo.


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\MAX
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\MAX

:: Run MAX
echo Running pollination_MAXOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_MAXOrg.json" -w "%OUTPUT_DIR%"   
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
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "BAU" "FALSE" "FALSE"

:: Run OF
echo Running 4_INVEST_Output_Preparation.R for OF...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "OF" "FALSE" "FALSE"

:: Run MAX
echo Running INVEST_Output_Preparation...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "MAX" "FALSE" "FALSE"










:: -----------------------------
:: Sensitivity analysis 50minus
:: -----------------------------

set folder=sensitivity_analysis/%1/50minus
set folder_PALUD=sensitivity_analysis/null

:: -----------------------------
:: Run 1_XLSXtoSHP.R
:: -----------------------------
set R_SCRIPT_PATH_1=C:\git\BEATLE\PALUD_InVEST\R_skripts\1_XLSXtoSHP.R


echo Running 1_XLSXtoSHP - RUN BAU
Rscript "%R_SCRIPT_PATH_1%" "2030" "BAU" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN BAU failed. See R output for details.
     pause
)

echo Running 1_XLSXtoSHP - RUN OF
Rscript "%R_SCRIPT_PATH_1%" "2030" "OF" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN OF failed. See R output for details.
    pause
)

echo Running 1_XLSXtoSHP - RUN 4
Rscript "%R_SCRIPT_PATH_1%" "2030" "MAX" "C:/git/BEATLE/PALUD/PALUD_aggregated/Output/%folder_PALUD%"

IF %ERRORLEVEL% NEQ 0 (
    echo Running 1_XLSXtoSHP - RUN 4 failed. See R output for details.
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
REM #'   \item sens_id: ID for sensitivity analysis (e.g., "%1")
REM #' }

set R_SCRIPT_PATH_2=C:\git\BEATLE\PALUD_InVEST\R_skripts\2_INVEST_INPUTDATA_PALUDorg.R


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN BAU
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "BAU" "2030" "BAU" "FALSE" "FALSE" "TRUE" ""

echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN OF
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "OF" "2030" "OF" "FALSE" "FALSE" "TRUE" ""


echo Running 2_INVEST_INPUTDATA_PALUDorg - RUN 4 
Rscript "%R_SCRIPT_PATH_2%" "C:/git/BEATLE/InVEST/WORKBENCH/input/%folder%" "MAX" "2030" "MAX" "FALSE" "FALSE" "TRUE" ""


:: -----------------------------
:: Run InVEST
:: -----------------------------

:: Set paths
set INVEST_EXE="C:\git\BEATLE\InVEST\WORKBENCH\InVEST 3.13.0 Workbench\resources\invest\invest.exe"


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\BAU
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\BAU

:: Run BAU
echo Running pollination_BAUOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_BAUOrg.json" -w "%OUTPUT_DIR%"
echo.

set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\OF
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\OF

:: Run OF
echo Running pollination_OFOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_OFOrg.json" -w "%OUTPUT_DIR%"
echo.


set INPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\input\%folder%\MAX
set OUTPUT_DIR=C:\git\BEATLE\InVEST\WORKBENCH\results\%folder%\MAX

:: Run MAX
echo Running pollination_MAXOrg.json...
%INVEST_EXE% -vvv run pollination -d "%INPUT_DIR%\pollination_MAXOrg.json" -w "%OUTPUT_DIR%"   
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
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/BAU" "BAU" "FALSE" "FALSE"

:: Run OF
echo Running 4_INVEST_Output_Preparation.R for OF...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/OF" "OF" "FALSE" "FALSE"

:: Run MAX
echo Running INVEST_Output_Preparation...
Rscript "%R_SCRIPT_PATH_3%" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "C:/git/BEATLE/InVEST/WORKBENCH/results/%folder%/MAX" "MAX" "FALSE" "FALSE"
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


