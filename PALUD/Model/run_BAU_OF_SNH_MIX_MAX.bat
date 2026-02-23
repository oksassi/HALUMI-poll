setlocal enabledelayedexpansion


:: Store start time
for /f "delims=" %%a in ('powershell -command "Get-Date -Format o"') do set "start_time=%%a"
:: -----------------------------
:: Run Data_input.gms
:: -----------------------------
::echo Running Data_Input.gms
::gams Data_Input.gms s=.\t\BW 
set folder=EE-v2
:: -----------------------------
:: Run BAU
:: -----------------------------


echo Running Model_optimisation.gms 
gams Model_optimisation.gms r=./t/BW s= ./t/BW_opt --org_increase_upper=0.73 --org_increase_lower=0.73

set "gdxVal=C:\git\BEATLE\PALUD\PALUD_aggregated\Output\!folder!\BAU.gdx"
set "outdirVal=Output\!folder!"
echo Running SIM.gms
gams SIM.gms --outdir=!outdirVal! r=./t/BW_opt --SIM="BAU" GDX=!gdxVal!
echo Output directory !outdirVal!

:: -----------------------------
:: Run OF 35%
:: -----------------------------
echo Running Model_optimisation.gms 
gams Model_optimisation.gms r=./t/BW s= ./t/BW_opt --org_increase_upper=2.74 --org_increase_lower=2.74

set "gdxVal=C:\git\BEATLE\PALUD\PALUD_aggregated\Output\!folder!\OF.gdx"
set "outdirVal=Output\!folder!"
echo Running SIM.gms
gams SIM.gms --outdir=!outdirVal! r=./t/BW_opt --SIM="OF" GDX=!gdxVal!
echo Output directory !outdirVal!

:: -----------------------------
:: Run SNH 
:: -----------------------------
set "padded=0777"
set "floatVal=0.777"
set sim=SNH

REM Construct folder name
set "rVal=.\t\BW_opt_snh_!padded!"

set "gdxVal=C:\git\BEATLE\PALUD\PALUD_aggregated\Output\!folder!\!sim!_!padded!.gdx"
set "outdirVal=Output\!folder!\!sim!_!padded!"
echo Output directory should be !outdirVal!
echo Running Model_optimisation.gms 
gams Model_optimisation.gms r=./t/BW s=!rval! --org_increase_upper=0.73 --org_increase_lower=0.73 --snh_increase=!floatVal!

REM Run GAMS with parameters
gams SIM.gms --outdir=!outdirVal! r=!rVal! GDX=!gdxVal! --SIM=!sim!
echo Output directory !outdirVal!

:: -----------------------------
:: Run MIX
:: -----------------------------

set "padded=0413"
set "floatVal=0.413"
set sim=MIX

REM Construct folder name
set "rVal=.\t\BW_opt_!sim!_!padded!"
set "sVal=.\t\BW_res_!sim!_!padded!"

set "gdxVal=C:\git\BEATLE\PALUD\PALUD_aggregated\Output\!folder!\!sim!_!padded!.gdx"
set "outdirVal=Output\!folder!\!sim!_!padded!"
echo Output directory should be !outdirVal!
echo Running Model_optimisation.gms 
gams Model_optimisation.gms r=./t/BW s=!rval! --org_increase_upper=1.61 --org_increase_lower=1.61 --snh_increase=!floatVal!

REM Run GAMS with parameters
gams SIM.gms --outdir=!outdirVal! r=!rVal! s=!sVal! GDX=!gdxVal! --SIM=!sim!
echo Output directory !outdirVal!

:: -----------------------------
:: Run MAX
:: -----------------------------
set "padded=0777"
set "floatVal=0.777"
set sim=MAX

REM Construct folder name
set "rVal=.\t\BW_opt_snh_!padded!"

set "gdxVal=C:\git\BEATLE\PALUD\PALUD_aggregated\Output\!folder!\!sim!_!padded!.gdx"
set "outdirVal=Output\!folder!"
echo Output directory should be !outdirVal!
echo Running Model_optimisation.gms 
gams Model_optimisation.gms r=./t/BW s=!rval! --org_increase_upper=2.74 --org_increase_lower=2.74 --snh_increase=!floatVal!

REM Run GAMS with parameters
gams SIM.gms --outdir=!outdirVal! r=!rVal! GDX=!gdxVal! --SIM=!sim!
echo Output directory !outdirVal!

:: -----------------------------
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
