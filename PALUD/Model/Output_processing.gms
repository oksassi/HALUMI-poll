$title Export existing results from GDX file

* =============================================================================
* Configuration
* =============================================================================


$if not set SIM $set SIM MAX
$if not set padded $set padded 0777
$if not set filepath $set filepath C:\git\BEATLE\PALUD\PALUD_aggregated
$if not set folder $set folder EE-v2
$if not set outdir $set outdir Output\%folder%\%SIM%_%padded%

* =============================================================================
* Declare and load parameters directly from GDX
* =============================================================================


Parameter fields(*,*,*,*);
Parameter fields_type(*,*,*,*,*,*);
Parameter results_crop(*,*,*,*);
Parameter total(*);

$gdxin %filepath%\Output\%folder%\%SIM%_%padded%.gdx
$load fields fields_type results_crop total
$gdxin

* =============================================================================
* Export to Excel
* =============================================================================

* ----- fields -----
$onEcho > titles.txt
text="Schlag_ID" rng=fields!A1
text="K_PALUD" rng=fields!B1
text="AGS" rng=fields!C1
text="Year" rng=fields!D1
text="n" rng=fields!E1
$offEcho

execute_unload "%filepath%\Output\fields_%SIM%.gdx" fields;
execute "gdxxrw.exe %filepath%\Output\fields_%SIM%.gdx o=%filepath%\%outdir%\fields_%SIM%.xlsx par=fields rng=fields!A2 rdim=4 @titles.txt";

* ----- fields_type -----
$onEcho > titles_type.txt
text="Schlag_ID" rng=fields_type!A1
text="Soil" rng=fields_type!B1
text="Size" rng=fields_type!C1
text="K_PALUD" rng=fields_type!D1
text="Type" rng=fields_type!E1
text="Year" rng=fields_type!F1
text="n" rng=fields_type!G1
$offEcho

execute_unload "%filepath%\Output\fields_type_%SIM%.gdx" fields_type;
execute "gdxxrw.exe %filepath%\Output\fields_type_%SIM%.gdx o=%filepath%\%outdir%\fields_type_%SIM%.xlsx par=fields_type rng=fields_type!A2 rdim=5 @titles_type.txt";

* ----- results_crop -----
execute_unload "%filepath%\Output\results_%SIM%.gdx" results_crop;
execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par=results_crop rng=results_crop!A1";

* ----- total -----
execute_unload "%filepath%\Output\total_%SIM%.gdx" total;
execute "gdxxrw.exe %filepath%\Output\total_%SIM%.gdx o=%filepath%\%outdir%\total_%SIM%.xlsx par=total rng=total!A1";

display "Export complete!";

