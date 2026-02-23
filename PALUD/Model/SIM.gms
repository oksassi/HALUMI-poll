* r=./t/BW_opt
baserun('base') = 1;
$if not set outdir $set outdir Output
$if not set SIM $setglobal SIM BAU
$if not set demand_elasticity $set demand_elasticity -1
scalar demand_elasticity /%demand_elasticity%/;
set simulation /BAU, OF, SNH, test, MIX, MAX/;
set sim(simulation) /%SIM%/;


Loop(model_year,

* A. Set all variables to 0
$include utility_functions/variables_reset.gms
    
* B. Run model
    if (baserun(model_year),
      display "Running model Base";
      Solve Base using LP maximizing NETRETURN;
      if (Base.modelstat = 4 OR Base.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    elseif ( sim("BAU")),
      display "Running model Farm";
      Solve Farm using LP maximizing NETRETURN;
      if (Farm.modelstat = 4 OR Farm.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    elseif (sim("test")),
      display "Running model test_OF";
      Solve test_OF using LP maximizing NETRETURN;
      if (test_OF.modelstat = 4 OR test_OF.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    elseif (sim("OF")),
      display "Running model FarmOF";
      Solve FarmOF using LP maximizing NETRETURN;
      if (FarmOF.modelstat = 4 OR FarmOF.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    elseif (sim("SNH")),
      display "Running model SNH";
      Solve FarmSNH using LP maximizing NETRETURN;
      if (FarmSNH.modelstat = 4 OR FarmSNH.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    elseif (sim("MIX")),
      display "Running model MIX";
      Solve FarmMIX using LP maximizing NETRETURN;
      if (FarmMIX.modelstat = 4 OR FarmMIX.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    elseif (sim("MAX")),
      display "Running model MAX";
      Solve FarmMAX using LP maximizing NETRETURN;
      if (FarmMAX.modelstat = 4 OR FarmMAX.ObjVal < 0,
        display "Model is infeasible. Stopping loop.";
        abort "Infeasible model encountered at iteration", model_year;
      );
    );

* C. Analyze binding constraints (NEW STEP; optional)
*$include Binding_Constraints_Analysis.gms
 
* D. Format model output
$include format_model_year_results.gms

* E. Set model parameters for next year
$include utility_functions/update_annual_variables.gms


                
);


*Execute_unload '%filepath%\Output\LanduseResult_%SIM%.gdx', Landuse;
*
*Execute 'GDXXRW.EXE %filepath%\Output\LanduseResult_%SIM%.gdx par=Landuse cdim=1 rdim=2';

*
** SO 24-09-2024: Add results similar to fields.xlsx. One sheet per year
Parameter fields(Schlag_ID, crop, Kommune, model_year);
fields(Schlag_ID, crop, Kommune, model_year) = Landuse(Schlag_ID, crop, model_year)*Location(Schlag_ID, Kommune);

  
$onEcho > titles.txt

text="Schlag_ID" rng=fields!A1
text="K_PALUD" rng=fields!B1
text="AGS" rng = fields!C1
text = "Year" rng=fields!D1
text = "n" rng= fields!E1

$offEcho
* Save the data for the current model_year into a GDX file
execute_unload "%filepath%\Output\fields_%SIM%.gdx" fields;
* Use gdxxrw to write to a specific sheet for each model_year
execute "gdxxrw.exe %filepath%\Output\fields_%SIM%.gdx o=%filepath%\%outdir%\fields_%SIM%.xlsx par = fields rng = fields!A2 rdim = 4 @titles.txt";


* SO 04-06-2025: save field characteristics with land use on field
Parameter fields_type(Schlag_ID, soil, size, crop, type, model_year);
fields_type(Schlag_ID, soil, size, crop, type, model_year) = Landuse(Schlag_ID, crop, model_year)*
    Schlag_BG(Schlag_ID, soil, size)*type_of_crop(crop, type);
    
$onEcho > titles_type.txt

text="Schlag_ID" rng=fields_type!A1
text="Soil" rng=fields_type!B1
text="Size" rng=fields_type!C1
text="K_PALUD" rng=fields_type!D1
text="Type" rng = fields_type!E1
text = "Year" rng=fields_type!F1
text = "n" rng= fields_type!G1

$offEcho
* Save the data for the current model_year into a GDX file
execute_unload "%filepath%\Output\fields_type_%SIM%.gdx" fields_type;
* Use gdxxrw to write to a specific sheet for each model_year
execute "gdxxrw.exe %filepath%\Output\fields_type_%SIM%.gdx o=%filepath%\%outdir%\fields_type_%SIM%.xlsx par = fields_type rng = fields_type!A2 rdim = 5 @titles_type.txt";


** SO 26-09-2024: Save results
*execute_unload "%filepath%\Output\results_%SIM%.gdx" results_kom results_kom_perc results_organic_share results_crop res_crop_group_share res_precrop_crop result_plot_switch results_crop_NR results_CU res_lsu;
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_kom rng=results_kom!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_kom_perc rng=results_kom_perc!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_organic_share rng=results_organic_share!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_crop rng=results_crop!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = res_crop_group_share rng=res_crop_group_share!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = res_precrop_crop rng=res_precrop_crop!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = result_plot_switch rng=result_plot_switch!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_crop_NR rng=results_crop_NR!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_CU rng=results_CU!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = res_lsu rng=results_lsu!A1";
*
execute_unload "%filepath%\Output\results_%SIM%.gdx"  results_crop;
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_kom rng=results_kom!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_kom_perc rng=results_kom_perc!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_organic_share rng=results_organic_share!A1";
execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_crop rng=results_crop!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = res_crop_group_share rng=res_crop_group_share!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = res_precrop_crop rng=res_precrop_crop!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = result_plot_switch rng=result_plot_switch!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_crop_NR rng=results_crop_NR!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = results_CU rng=results_CU!A1";
*execute "gdxxrw.exe %filepath%\Output\results_%SIM%.gdx o=%filepath%\%outdir%\results_%SIM%.xlsx par = res_lsu rng=results_lsu!A1";
*


parameter total(*);
total("nr")               = NETRETURN.L;
total("nr_wo_subs")       = NETRETURN.L - sum(Kommune, PREM_OF.L(Kommune)) - sum(Kommune, PREM_SNH.L(Kommune));
total("nr_org")           = sum(Kommune, NETRET_ORG.L(Kommune));
total("nr_conv")          = total("nr_wo_subs") - total("nr_org");
total("subsidy")          = sum(Kommune, PREM_OF.L(Kommune)) + sum(Kommune, PREM_SNH.L(Kommune));
total("premium_of")       = sum(Kommune, PREM_OF.L(Kommune));
total("premium_snh")      = sum(Kommune, PREM_SNH.L(Kommune));
total("CU")               = sum(Kommune, CEREAL_UNITS.L(Kommune));
total("CU_fodder")        = sum((Kommune, crop, ls), FODDER_PROD1.L(Kommune,ls,crop)*ge(crop));
total("CU_sale")          = total("CU") - total("CU_fodder");
total("bought_feed")      = sum((Kommune, crop, ls), BOUGHT_FEED.l(Kommune, ls, crop)*ge(crop));
total("bought_feed_org")  = sum((Kommune, ocrop, ls), BOUGHT_FEED.l(Kommune, ls, ocrop)*ge(ocrop));
total("bought_feed_conv") = sum((Kommune, kcrop, ls), BOUGHT_FEED.l(Kommune, ls, kcrop)*ge(kcrop));
total("lsu")              = sum((Kommune, ls, type), LS_PROD.l(Kommune, ls, type) * ls_unit(ls));
total("lsu_org")          = sum((Kommune, ls), LS_PROD.l(Kommune, ls, "org") * ls_unit(ls));
total("lsu_conv")         = sum((Kommune, ls), LS_PROD.l(Kommune, ls, "conv") * ls_unit(ls));
total("arable_of")        = results_organic_share_NUTS3("2030",'arable');
total("grassland_of")     = results_organic_share_NUTS3("2030",'grassland');



* SO 26-09-2024: Save results
execute_unload "%filepath%\Output\total_%SIM%.gdx" total;
execute "gdxxrw.exe %filepath%\Output\total_%SIM%.gdx o=%filepath%\%outdir%\total_%SIM%.xlsx par = total rng=total!A1";

*$include utility_functions/results_extraction_saskia.gms