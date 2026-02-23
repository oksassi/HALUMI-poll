HOW TO RUN THE MODEL
1) Create a new folder "t" in the folder "Model".
2) In folder "Model", run Data_Input.gms with "s = ./t/BW" (without quotes) in the GAMS command line. Therefore, you must first have created the folder "t" first.
3) Again in folder "Model", run Model_optimisation.gms with "s= ./t/BW_opt r=./t/BW" (again without quotes) in the GAMS command line.
4) Depending on your simulation study, run SIM.gms (or another experiment file of your choice) from the "Model" folder 
   with "r = .\t\BW_opt" in the GAMS command line. Output files you may create should be stored in the folder "Output".
5) Runs can be automated by using the R-scripts or batch files provided in the "Model" folder, e.g., run_MIX_SNH.R or run_BAU_OF_SNH_MIX_MAX.bat.
6) To create output xlsx files, you can run run_output_processing.R, which starts the gms file Output_processing.gms.

NOTE: Do not push the contents of folder "t" (BW.g00 and BW_opt.g00) to git. The files are far too big for git and should only be stored on your local machine. 
