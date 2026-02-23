
$ontext

Format the results for a single year of a model run

$offtext
*****************
*  Model Output *
*****************
    modelled_landuse(Schlag_ID,crop)$(CROPPROD.L(Schlag_ID,crop) and sum(Kommune,Location(Schlag_ID,Kommune))) = 1$(CROPPROD.L(Schlag_ID,crop) eq smax(crop2,CROPPROD.L(Schlag_ID,crop2)));


*** GENERAL: Organic Shares ***
    total_area(Kommune,'all') = sum((crop),CROP_KOMMUNE.l(Kommune, crop));
    total_area(Kommune,'arable') = sum((crop)$(not Gcrop(crop)),CROP_KOMMUNE.l(Kommune,crop));
    total_area(Kommune,'grassland') = sum((crop)$(Gcrop(crop)),CROP_KOMMUNE.l(Kommune,crop));
    
    results_organic_share(model_year,Kommune,'all')$total_area(Kommune,'all') = sum(oCrop$(not Bcrop(ocrop)),CROP_KOMMUNE.l(Kommune, oCrop)) / total_area(Kommune,'all') * 100;
    results_organic_share(model_year,Kommune,'arable')$total_area(Kommune,'arable') = sum((oCrop)$(not Gcrop(oCrop) AND not Bcrop(ocrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area(Kommune,'arable')*100;
    results_organic_share(model_year,Kommune,'grassland')$total_area(Kommune,'grassland') = sum((oCrop)$(Gcrop(oCrop) AND not Bcrop(ocrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area(Kommune,'grassland')*100;
    
    results_organic_share_NUTS3(model_year,'all')$total_area_NUTS3('all') = sum((oCrop, Kommune)$(not Bcrop(ocrop)),CROP_KOMMUNE.l(Kommune, oCrop)) / total_area_NUTS3('all') * 100;
    results_organic_share_NUTS3(model_year,'arable')$total_area_NUTS3('arable') = sum((oCrop, Kommune)$(not Gcrop(oCrop) AND not Bcrop(ocrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area_NUTS3('arable')*100;
    results_organic_share_NUTS3(model_year,'grassland')$total_area_NUTS3('grassland') = sum((oCrop, Kommune)$(Gcrop(oCrop) AND not Bcrop(ocrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area_NUTS3('grassland')*100;

*** SNH Shares ***
    results_SNH_share(model_year,Kommune, 'all')$total_area(Kommune,'all') = sum((bCrop),CROP_KOMMUNE.l(Kommune, bCrop)) / total_area(Kommune,'all') * 100;
    results_SNH_share(model_year,Kommune, 'arable')$total_area(Kommune,'arable') = sum((bCrop_arable),CROP_KOMMUNE.l(Kommune, bCrop_arable)) / total_area(Kommune,'arable') * 100;
*    results_SNH_share(model_year,Kommune, 'grassland')$total_area(Kommune,'grassland') = sum((not bCrop_arable),CROP_KOMMUNE.l(Kommune, not bCrop_arable)) / total_area(Kommune,'grassland') * 100;

    results_SNH_share_NUTS3(model_year, 'all')$total_area_NUTS3('all') = sum((bCrop, Kommune),CROP_KOMMUNE.l(Kommune, bCrop)) / total_area_NUTS3('all') * 100;
    results_SNH_share_NUTS3(model_year, 'arable')$total_area_NUTS3('arable') = sum((bCrop_arable, Kommune),CROP_KOMMUNE.l(Kommune, bCrop_arable)) / total_area_NUTS3('arable') * 100;
    results_SNH_share_NUTS3(model_year, 'grassland')$total_area_NUTS3('grassland') = (sum(Kommune,CROP_KOMMUNE.l(Kommune, "oBG")) + sum (Kommune, CROP_KOMMUNE.l(Kommune, "BG"))) / total_area_NUTS3('grassland') * 100;

    results_SNH_share_detailed_NUTS3(model_year, 'all', bCrop)$total_area_NUTS3('all') = sum(Kommune, CROP_Kommune.l(Kommune, bCrop)) / total_area_NUTS3('all')*100;
    results_SNH_share_detailed(model_year,Kommune, 'all', bCrop)$total_area(Kommune, 'all') = CROP_Kommune.l(Kommune, bCrop) / total_area(Kommune,'all')*100;
    
*** LIVESTOCK FEED RATIONS ***
    ls_feed(model_year, Kommune, ls, type, crop)$(LS_PROD.l(Kommune,ls,type) > 0) =
        (BOUGHT_FEED.L(Kommune, ls, crop)+FODDER_PROD1.l(Kommune,ls,crop))*type_of_crop(crop,type) / 365 / LS_PROD.l(Kommune,ls,type) * 100;
    ls_bought_share(model_year, Kommune, ls, type, crop)$((BOUGHT_FEED.L(Kommune, ls, crop) + FODDER_PROD1.L(Kommune,ls,crop)) * type_of_crop(crop,type)) =
         BOUGHT_FEED.L(Kommune, ls, crop)*type_of_crop(crop,type) /
         ((BOUGHT_FEED.L(Kommune, ls, crop) + FODDER_PROD1.L(Kommune,ls,crop)) * type_of_crop(crop,type));

*    ls_bought_share(model_year, Kommune, ls, type, crop)$((BOUGHT_FEED.L(Kommune, ls, crop)+(FODDER_PROD1.L(Kommune,ls,crop))*type_of_crop(crop,type))) =
*        BOUGHT_FEED.L(Kommune, ls, crop)*type_of_crop(crop,type) / ((BOUGHT_FEED.L(Kommune, ls, crop)+FODDER_PROD1.L(Kommune,ls,crop))*type_of_crop(crop,type));
    ls_boughtfeed_tot(model_year,Kommune,crop) = sum(ls,BOUGHT_FEED.L(Kommune,ls,crop));
    crop_share_fed(model_year, Kommune, crop)$PRODUCTION_KOM.L(Kommune,crop) = sum(ls,FODDER_PROD1.L(Kommune,ls,crop)) / PRODUCTION_KOM.L(Kommune,crop);
    DGr_dm_per_ha(model_year,Kommune)$total_area(Kommune,'grassland') = sum(Gcrop,PRODUCTION_KOM.L(Kommune,Gcrop)*dry_matter_content(Gcrop)) / total_area(Kommune,'grassland');

*** NET RETURN ***
*    results_kom(model_year,Kommune,"netreturns")  = NETRETURN_MUNI.L(Kommune);
*    results_kom(model_year,Kommune,"totalNR") = NETRETURN.L;
*    results_kom(model_year,Kommune,"dbha")$total_area(Kommune,'all')  = NETRETURN_MUNI.L(Kommune)/total_area(Kommune,'all');
*    results_kom(model_year,Kommune,"organicshare")$total_area(Kommune,'all') = sum((oCrop),CROP_KOMMUNE.l(Kommune, oCrop)) / total_area(Kommune,'all') * 100;
*    results_kom(model_year,Kommune,'feedcost') = sum((ls,crop),BOUGHT_FEED.L(Kommune,ls,crop)*Price(crop)*transport_fee)
*                                            + sum((crop,ls),FODDER_PROD1.L(Kommune,ls,crop)*Price(crop));
*    results_kom_perc(model_year,Kommune,res)$results_kom("base",Kommune,res) = (results_kom(model_year,Kommune,res) / results_kom("base",Kommune,res) -1)*100;
*
**** ORGANIC NET RETURNS ***
** SO 16-01-2025
*    results_kom(model_year,Kommune,"netreturns_org")  = NETRET_ORG.L(Kommune);
*    results_kom(model_year,Kommune,"netreturns_ls")  = NETRET_LS.L(Kommune);
*    results_kom(model_year,Kommune,"netreturns_ls_org")  = NETRET_LS_ORG.L(Kommune);
*    results_kom(model_year,Kommune,"dbha_org")$(total_area(Kommune,'all') AND results_kom(model_year,Kommune,"organicshare")) = NETRET_ORG.L(Kommune)*100/(results_kom(model_year,Kommune,"organicshare")*total_area(Kommune,'all'));
*    results_kom(model_year,Kommune,"totalpremium")  = PREM.L(Kommune);
*    
*** TOTAL AREA CALCULATIONS ***
* SO 17-01-2025
*    area(model_year, Kommune,'grassland',type) = sum((Gcrop, Schlag_ID)$type_of_crop(Gcrop, type),CROPPROD.L(Schlag_ID, Gcrop));
*    area(model_year, Kommune,'arable',type) = sum((Acrop, Schlag_ID)$type_of_crop(Acrop, type),CROPPROD.L(Schlag_ID, Acrop));
*    area(model_year, Kommune,'all',type) = sum((crop, Schlag_ID)$type_of_crop(crop, type),CROPPROD.L(Schlag_ID, crop));
    area(model_year, Kommune,'grassland') = sum((crop, Schlag_ID)$(Gcrop(crop) AND Location(Schlag_ID, Kommune)),CROPPROD.L(Schlag_ID, crop));
    area(model_year, Kommune,'arable') = sum((Acrop, Schlag_ID)$Location(Schlag_ID, Kommune),CROPPROD.L(Schlag_ID, Acrop));
    area(model_year, Kommune,'all') = sum((crop, Schlag_ID)$Location(Schlag_ID, Kommune),CROPPROD.L(Schlag_ID, crop));
*** CEREAL UNITS ***
* SO 17-01-2025
*    results_cu(model_year, Kommune) = CEREAL_UNITS.L(Kommune);
*
**** NET RETURN PER CROP ***
*    results_crop_NR(model_year, Kommune, "netreturns", crop) = NETRETURN_CROPS.L(Kommune, crop);
*    
**** CROP SHARES ***
    results_crop(model_year, Kommune, crop, 'cultivatedarea') = CROP_KOMMUNE.l(Kommune,crop);
    results_crop(model_year, Kommune, crop, 'areaincrease')$Landuse_SQ(Kommune,crop)   = (CROP_KOMMUNE.l(Kommune,crop)/Landuse_SQ(Kommune,crop))*100 - 100;
    results_crop(model_year, Kommune, crop, 'production')    = PRODUCTION_KOM.l(Kommune, crop);
    results_crop(model_year, Kommune, crop, 'biogas_fodder') = sum(substrate_fodder,FODDER_BIOGAS.l(Kommune, crop, substrate_fodder));
    results_crop(model_year, Kommune, crop, 'animal_fodder') = sum(ls, FODDER_PROD1.l(Kommune, ls, crop));
    results_crop(model_year, Kommune, crop, 'sold')          = CROP_SALE.l(Kommune, crop);
    results_crop(model_year, Kommune, crop, 'bought')        = sum(ls, BOUGHT_FEED.l(Kommune, ls, crop));
    Kom_tot_crop(model_year, Kommune, oCrop) = CROP_KOMMUNE.L(kommune,oCrop) + SUM(kCrop, map_konv_org(kCrop, oCrop) * CROP_KOMMUNE.L(kommune,kCrop));
    Kom_tot_crop_inc(model_year,Kommune,oCrop)$Landuse_SQ_crop(Kommune,oCrop) = Kom_tot_crop(model_year, Kommune, oCrop)/Landuse_SQ_crop(Kommune,oCrop);
    Kom_tot_crop_NUTS3(model_year, oCrop) = sum(Kommune, Kom_tot_crop(model_year, Kommune, oCrop));
    
**** CROP ROTATION ***
*    res_precrop_crop(model_year, Kommune, Schlag_ID, crop, crop2) = Location(Schlag_ID,Kommune) * precrop(Schlag_ID, crop) * CROPPROD.L(Schlag_ID, crop2);
*    res_crop_group_share(model_year, Kommune, cgroup,type)$CULTIV_AREA.L(Kommune,type) = sum(crop$(cropsin(cgroup,crop) and type_of_crop(crop, type)), CROP_KOMMUNE.L(Kommune,crop)) / CULTIV_AREA.L(Kommune,type) * 100;
*    vorfruchtwert(model_year,Kommune,type)$CULTIV_AREA.L(Kommune, type) = sum(Schlag_ID$(Location(Schlag_ID, Kommune) and not GL_ID(Schlag_ID)), sum(crop$type_of_crop(crop, type), CROPPROD.L(Schlag_ID,crop) * sum(crop2, combival_P(crop, crop2)))) / CULTIV_AREA.L(Kommune, type);
*    
**** DIVIDED PLOTS ***
*    result_divided_plots(model_year, Schlag_ID) = 1$(smax(crop2,CROPPROD.L(Schlag_ID,crop2)) < Schlag_ha(Schlag_ID));
*    count_divided_plots(model_year) = sum(Schlag_ID,result_divided_plots(model_year, Schlag_ID));
*    
**** PLOT SWITCHES ***              
*    result_plot_switch(model_year,Schlag_ID,Gcrop,crop,'grass_to_org')$(type_of_crop(crop,'org') and type_of_crop(Gcrop,'conv'))
*        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
*    result_plot_switch(model_year,Schlag_ID,Gcrop,crop,'grass_to_conv')$(type_of_crop(crop,'conv') and type_of_crop(Gcrop,'org'))
*        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
*    result_plot_switch(model_year,Schlag_ID,crop,Gcrop,'conv_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'conv'))
*        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
*    result_plot_switch(model_year,Schlag_ID,crop,Gcrop,'org_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'org'))
*        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
*    ha_plot_switch(model_year,switch2) = sum((Schlag_ID,crop,crop2),result_plot_switch(model_year,Schlag_ID,crop,crop2,switch2));
*    
*    plots_plot_switch(model_year,Schlag_ID,Gcrop,crop,'grass_to_org')$(type_of_crop(crop,'org') and type_of_crop(Gcrop,'conv'))
*        = 1$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
*    plots_plot_switch(model_year,Schlag_ID,Gcrop,crop,'grass_to_conv')$(type_of_crop(crop,'conv') and type_of_crop(Gcrop,'org'))
*        = 1$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
*    plots_plot_switch(model_year,Schlag_ID,crop,Gcrop,'conv_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'conv'))
*        = 1$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
*    plots_plot_switch(model_year,Schlag_ID,crop,Gcrop,'org_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'org'))
*        = 1$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
*    count_plot_switch(model_year, switch2) = sum((Schlag_ID, crop, crop2),plots_plot_switch(model_year,Schlag_ID,crop,crop2,switch2));
*    
*    plot_count(model_year) = sum(Schlag_ID$(sum(Kommune,Location(Schlag_ID,Kommune))),1);
*    plot_switch_perc(model_year, switch) = count_plot_switch(model_year,switch) / plot_count(model_year);

*** LIVESTOCK NUMBERS AS VARIABLE ***
* MR this section helps to evaluate the effect of livestock numbers set as a variable (LS_PROD)
ls_no_animals(model_year,Kommune,ls,type) = LS_PROD.L(Kommune, ls, type);
ls_total_animal(model_year,Kommune) = sum((ls,type),LS_PROD.L(Kommune, ls, type));
ls_total_lsu(model_year,Kommune) = sum((ls,type),LS_PROD.L(Kommune, ls, type)*ls_unit(ls));
ls_org_share(model_year,Kommune, ls)$sum(type,LS_PROD.L(Kommune, ls, type)) = LS_PROD.L(Kommune, ls, 'org') / sum(type,LS_PROD.L(Kommune, ls, type));
ls_org_share_tot(model_year, Kommune)$ls_total_animal(model_year,Kommune) = sum(ls,LS_PROD.L(Kommune, ls, 'org')) / ls_total_animal(model_year,Kommune);
ls_yearly_inc(model_year,Kommune, ls, type)$temp_no_animals(Kommune, ls, type)  = (LS_PROD.L(Kommune, ls, type) - temp_no_animals(Kommune,ls,type)) / temp_no_animals(Kommune, ls, type);
temp_no_animals(Kommune, ls, type) = LS_PROD.L(Kommune, ls, type);

res_lsu(model_year, Kommune,ls,type) = LS_PROD.l(Kommune, ls, type) * ls_unit(ls);
res_lsu_herb(model_year, Kommune, type) = sum(ls$ls_herb(ls), LS_PROD.l(Kommune, ls, type) * ls_unit(ls));
res_fodder_area(model_year, Kommune,type) = sum(fodder_crop$type_of_crop(fodder_crop,type), CROP_KOMMUNE.l(Kommune, fodder_crop));
res_grass_area(model_year, Kommune, type) = sum(gcrop$type_of_crop(gcrop,type), CROP_KOMMUNE.l(Kommune, gcrop));
res_lsu_herb_ha(model_year,Kommune, type)$res_fodder_area(model_year,Kommune, type) = res_lsu_herb(model_year,Kommune, type) / res_fodder_area(model_year, Kommune, type);
res_lsu_herb_ha_grass(model_year, Kommune, type) =
    res_lsu_herb(model_year, Kommune, type)/ res_grass_area(model_year, Kommune, type);
res_bought_feed(model_year, Kommune, type) = sum((crop, ls)$type_of_crop(crop, type), BOUGHT_FEED.l(Kommune, ls, crop));
res_fodder_prod(model_year, Kommune, crop) = sum(ls, FODDER_PROD1.L(Kommune,ls,crop));

*** LABOR ***
lab_ls(model_year,Kommune,timeframe)$lab_avail(Kommune, timeframe) = (sum((ls,type), lab_dem_ls(ls)*LS_PROD.L(Kommune,ls,type)) / 24) / lab_avail(Kommune, timeframe);
lab_crop(model_year,Kommune,timeframe)$lab_avail(Kommune, timeframe) = sum(Schlag_ID$Location(Schlag_ID,Kommune),
        sum((crop, soil, size)$Schlag_BG(Schlag_ID, soil, size),
            CROPPROD.L(Schlag_ID, crop) * lab_dem(crop, soil, size, timeframe)))
            / lab_avail(Kommune, timeframe);
lab_ls_tot(model_year,Kommune)$sum(timeframe,lab_avail(Kommune, timeframe)) = sum((ls,type), lab_dem_ls(ls)*LS_PROD.L(Kommune,ls,type)) / sum(timeframe,lab_avail(Kommune, timeframe));
lab_crop_tot(model_year,Kommune)$sum(timeframe,lab_avail(Kommune, timeframe)) = sum(Schlag_ID$Location(Schlag_ID,Kommune),
        sum((crop, soil, size,timeframe)$Schlag_BG(Schlag_ID, soil, size),
            CROPPROD.L(Schlag_ID, crop) * lab_dem(crop, soil, size, timeframe)))
            / sum(timeframe,lab_avail(Kommune, timeframe));
res_labor1(model_year, Kommune, timeframe, crop) = LABOR_CROP.l(Kommune, timeframe, crop);
res_labor2(model_year, Kommune, timeframe, ls, type) = LABOR_LS.l(Kommune, timeframe, ls, type);

*** PLANT NUTRIENT COVERAGE ***
*MR the following section helps to evaluate the availability of organic fertilizer
    area_(model_year,Kommune,type) = sum(crop$(type_of_crop(crop,type)),CROP_KOMMUNE.l(Kommune,crop));
    result_nutrients(model_year, Kommune, Duenger, type, 'avail_per_ha')$area_(model_year,Kommune,type) = ORG_FERT_AVAIL.l(Kommune, Duenger, type) / area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'demand_per_ha')$area_(model_year,Kommune,type) = sum(crop$type_of_crop(crop,type),PRODUCTION_KOM.l(Kommune,crop)*Duenger_M(crop,Duenger)) / area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'deficit_per_ha') = result_nutrients(model_year, Kommune, Duenger, type, 'demand_per_ha') - result_nutrients(model_year, Kommune, Duenger, type, 'avail_per_ha');
    result_nutrients(model_year, Kommune, Duenger, type, 'deficit_percent')$result_nutrients(model_year, Kommune, Duenger, type, 'demand_per_ha') = result_nutrients(model_year, Kommune, Duenger, type, 'deficit_per_ha') / result_nutrients(model_year, Kommune, Duenger, type, 'demand_per_ha') * 100;
    result_nutrients(model_year, Kommune, Duenger, type, 'from_R')$area_(model_year,Kommune,type)     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'R', type) - MANURE_CONVERSION_FROM.l(Kommune, 'R', type)) * map_ls_fert('R', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_M')$area_(model_year,Kommune,type)     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'M', type) - MANURE_CONVERSION_FROM.l(Kommune, 'M', type)) * map_ls_fert('M', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_S')$area_(model_year,Kommune,type)     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'S', type) - MANURE_CONVERSION_FROM.l(Kommune, 'S', type)) * map_ls_fert('S', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_H')$area_(model_year,Kommune,type)     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'H', type) - MANURE_CONVERSION_FROM.l(Kommune, 'H', type)) * map_ls_fert('H', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_Eh')$area_(model_year,Kommune,type)    = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'Eh', type) - MANURE_CONVERSION_FROM.l(Kommune, 'Eh', type)) * map_ls_fert('Eh', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_Sch')$area_(model_year,Kommune,type)   = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'Sch', type) - MANURE_CONVERSION_FROM.l(Kommune, 'Sch', type)) * map_ls_fert('Sch', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_Z')$area_(model_year,Kommune,type)     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'Z', type) - MANURE_CONVERSION_FROM.l(Kommune, 'Z', type)) * map_ls_fert('Z', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_biogas')$area_(model_year,Kommune,type)= (AMOUNT_BGL.l(Kommune, type) - BGL_CONVERSION_FROM.l(Kommune,type)) * fert_nut_cont('BGL',Duenger) * fert_eff('BGL', Duenger)/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'bought')$area_(model_year,Kommune,type)     = sum(ext_org_fert,FERT_BOUGHT.l(Kommune, ext_org_fert, type) * fert_nut_cont(ext_org_fert,Duenger) * fert_eff(ext_org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_conv_manure')$area_(model_year,Kommune,type)= sum((org_fert, ls), MANURE_CONVERSION_TO.l(Kommune, ls, type) * map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_conv_biogas')$area_(model_year,Kommune,type)= BGL_CONVERSION_TO.l(Kommune,type) * fert_nut_cont('BGL',Duenger) * fert_eff('BGL', Duenger)/ area_(model_year,Kommune,type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_intercrop')$area_(model_year,Kommune,type)= NUT_FROM_INTERCROP.l(Kommune, Duenger, type);
    result_nutrients(model_year, Kommune, Duenger, type, 'from_gm_maincrop')$area_(model_year,Kommune,type)= NUT_FROM_GMM.l(Kommune, Duenger, type);

*** BIOGAS PLANTS ***
* MR 17.02.2025 the nutrient ratio of the biogas digestate. should match fert_nut_conten('BGL', Duenger)
nut_cont_biogas(model_year, Kommune, Duenger, type)$AMOUNT_BGL.l(Kommune, type)=
    (sum((org_fert,ls), sum(substrate_manure,MANURE_BIOGAS.l(Kommune, ls, type, substrate_manure)) * map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, Duenger))
    + sum((crop,substrate_fodder),FODDER_BIOGAS.l(Kommune, crop,substrate_fodder)*Duenger_M(crop, Duenger)*type_of_crop(crop, type)))
    / AMOUNT_BGL.l(Kommune, type);
result_biogas_amount(model_year, Kommune, type) = AMOUNT_BGL.l(Kommune, type);
result_biogas1(model_year, Kommune, crop) = sum(substrate_fodder, FODDER_BIOGAS.l(Kommune, crop, substrate_fodder));
result_biogas2(model_year, Kommune, ls, type) = sum(substrate_manure, MANURE_BIOGAS.l(Kommune, ls, type, substrate_manure));


*** CROP-SPECIFIC ORGANIC SHARES ***
result_organic_share_NUTS3_crop_specific(model_year, ocrop)$Kom_tot_crop_NUTS3(model_year, ocrop) = sum(Kommune, results_crop(model_year, Kommune, oCrop, 'cultivatedarea'))
    / Kom_tot_crop_NUTS3(model_year, ocrop);