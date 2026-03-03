setlocal enabledelayedexpansion



:: -----------------------------
:: Run Sensitivity_analysis_p_abund.R
:: -----------------------------
set R_SCRIPT_PATH_1=C:\git\BEATLE\Saskia\R_skripts\INVEST_Output_Analysis_SingleCrops_P_ABUND_Y_TOT.R

set input_folder="C:/git/BEATLE/InVEST/WORKBENCH/results/sensitivity_analysis/%1/10minus"
set output_folder="C:/git/BEATLE/Saskia/R_skripts/sensitivity_analysis/%1/10minus"

echo Running 10minus
Rscript "%R_SCRIPT_PATH_1%" "%input_folder%" "%output_folder%" "BAU,OF,MAX" "" "Erd,SB,WR,apple" "OF"

set input_folder="C:/git/BEATLE/InVEST/WORKBENCH/results/sensitivity_analysis/%1/10plus"
set output_folder="C:/git/BEATLE/Saskia/R_skripts/sensitivity_analysis/%1/10plus"

echo Running 10plus
Rscript "%R_SCRIPT_PATH_1%" "%input_folder%" "%output_folder%" "BAU,OF,MAX" "" "Erd,SB,WR,apple" "OF"



set input_folder="C:/git/BEATLE/InVEST/WORKBENCH/results/sensitivity_analysis/%1/50minus"
set output_folder="C:/git/BEATLE/Saskia/R_skripts/sensitivity_analysis/%1/50minus"

echo Running 50minus
Rscript "%R_SCRIPT_PATH_1%" "%input_folder%" "%output_folder%" "BAU,OF,MAX" "" "Erd,SB,WR,apple" "OF"



set input_folder="C:/git/BEATLE/InVEST/WORKBENCH/results/sensitivity_analysis/%1/50plus"
set output_folder="C:/git/BEATLE/Saskia/R_skripts/sensitivity_analysis/%1/50plus"

echo Running 50plus
Rscript "%R_SCRIPT_PATH_1%" "%input_folder%" "%output_folder%" "BAU,OF,MAX" "" "Erd,SB,WR,apple" "OF"