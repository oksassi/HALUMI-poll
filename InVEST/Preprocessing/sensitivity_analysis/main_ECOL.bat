@echo off

::call palud_invest_ECOL.bat ECOL1
::call palud_invest_ECOL.bat ECOL2
call palud_invest_ECOL.bat ECOL3
call palud_invest_ECOL.bat ECOL4
call palud_invest_ECOL.bat ECOL5

call p_abund_sensitivity ECOL1
call p_abund_sensitivity ECOL2

call y_tot_sensitivity ECOL1
call y_tot_sensitivity ECOL2
call y_tot_sensitivity ECOL3
call y_tot_sensitivity ECOL4
call y_tot_sensitivity ECOL5

echo All scripts finished.
pause