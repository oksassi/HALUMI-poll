
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
    
    results_organic_share('base',Kommune,'all')$total_area(Kommune,'all') = sum((oCrop),CROP_KOMMUNE.l(Kommune, oCrop)) / total_area(Kommune,'all') * 100;
    results_organic_share('base',Kommune,'arable')$total_area(Kommune,'arable') = sum((oCrop)$(not Gcrop(oCrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area(Kommune,'arable')*100;
    results_organic_share('base',Kommune,'grassland')$total_area(Kommune,'grassland') = sum((oCrop)$(Gcrop(oCrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area(Kommune,'grassland')*100;
    
    results_organic_share_NUTS3('base','all')$total_area_NUTS3('all') = sum((oCrop, Kommune),CROP_KOMMUNE.l(Kommune, oCrop)) / total_area_NUTS3('all') * 100;
    results_organic_share_NUTS3('base','arable')$total_area_NUTS3('arable') = sum((oCrop, Kommune)$(not Gcrop(oCrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area_NUTS3('arable')*100;
    results_organic_share_NUTS3('base','grassland')$total_area_NUTS3('grassland') = sum((oCrop, Kommune)$(Gcrop(oCrop)),CROP_KOMMUNE.l(Kommune,oCrop)) / total_area_NUTS3('grassland')*100;

*** SNH Shares ***
    results_SNH_share('base',Kommune, 'all')$total_area(Kommune,'all') = sum((bCrop),CROP_KOMMUNE.l(Kommune, bCrop)) / total_area(Kommune,'all') * 100;
    results_SNH_share('base',Kommune, 'arable')$total_area(Kommune,'arable') = sum((bCrop_arable),CROP_KOMMUNE.l(Kommune, bCrop_arable)) / total_area(Kommune,'arable') * 100;
*    results_SNH_share('base',Kommune, 'grassland')$total_area(Kommune,'grassland') = sum((not bCrop_arable),CROP_KOMMUNE.l(Kommune, not bCrop_arable)) / total_area(Kommune,'grassland') * 100;

    results_SNH_share_NUTS3('base', 'all')$total_area_NUTS3('all') = sum((bCrop, Kommune),CROP_KOMMUNE.l(Kommune, bCrop)) / total_area_NUTS3('all') * 100;
    results_SNH_share_NUTS3('base', 'arable')$total_area_NUTS3('arable') = sum((bCrop_arable, Kommune),CROP_KOMMUNE.l(Kommune, bCrop_arable)) / total_area_NUTS3('arable') * 100;
*    results_SNH_share_NUTS3('base', 'grassland')$total_area_NUTS3('grassland') = sum((not bCrop_arable, Kommune),CROP_KOMMUNE.l(Kommune, not bCrop_arable)) / total_area_NUTS3('grassland') * 100;

*** LIVESTOCK FEED RATIONS ***
    ls_feed('base', Kommune, ls, type, crop)$(LS_PROD.l(Kommune,ls,type) > 0) =
        (BOUGHT_FEED.L(Kommune, ls, crop)+FODDER_PROD1.l(Kommune,ls,crop))*type_of_crop(crop,type) / 365 / LS_PROD.l(Kommune,ls,type) * 100;
    ls_bought_share('base', Kommune, ls, type, crop)$((BOUGHT_FEED.L(Kommune, ls, crop)*type_of_crop(crop,type))
        AND (BOUGHT_FEED.L(Kommune, ls, crop)*FODDER_PROD1.L(Kommune,ls,crop))) =
        BOUGHT_FEED.L(Kommune, ls, crop)*type_of_crop(crop,type) / ((BOUGHT_FEED.L(Kommune, ls, crop)+FODDER_PROD1.L(Kommune,ls,crop))*type_of_crop(crop,type));
*    ls_bought_share('base', Kommune, ls, type, crop)$((BOUGHT_FEED.L(Kommune, ls, crop)+(FODDER_PROD1.L(Kommune,ls,crop))*type_of_crop(crop,type))) =
*        BOUGHT_FEED.L(Kommune, ls, crop)*type_of_crop(crop,type) / ((BOUGHT_FEED.L(Kommune, ls, crop)+FODDER_PROD1.L(Kommune,ls,crop))*type_of_crop(crop,type));
    ls_boughtfeed_tot('base',Kommune,crop) = sum(ls,BOUGHT_FEED.L(Kommune,ls,crop));
    crop_share_fed('base', Kommune, crop)$PRODUCTION_KOM.L(Kommune,crop) = sum(ls,FODDER_PROD1.L(Kommune,ls,crop)) / PRODUCTION_KOM.L(Kommune,crop);
    DGr_dm_per_ha('base',Kommune)$total_area(Kommune,'grassland') = sum(Gcrop,PRODUCTION_KOM.L(Kommune,Gcrop)*dry_matter_content(Gcrop)) / total_area(Kommune,'grassland');

*** NET RETURN ***
    results_kom('base',Kommune,"netreturns")  = NETRETURN_MUNI.L(Kommune);
    results_kom('base',Kommune,"totalNR") = NETRETURN.L;
    results_kom('base',Kommune,"dbha")$total_area(Kommune,'all')  = NETRETURN_MUNI.L(Kommune)/total_area(Kommune,'all');
    results_kom('base',Kommune,"organicshare")$total_area(Kommune,'all') = sum((oCrop),CROP_KOMMUNE.l(Kommune, oCrop)) / total_area(Kommune,'all') * 100;
    results_kom('base',Kommune,'feedcost') = sum((ls,crop),BOUGHT_FEED.L(Kommune,ls,crop)*Price(crop)*transport_fee)
                                            + sum((crop,ls),FODDER_PROD1.L(Kommune,ls,crop)*Price(crop));
    results_kom_perc('base',Kommune,res)$results_kom("base",Kommune,res) = (results_kom('base',Kommune,res) / results_kom("base",Kommune,res) -1)*100;

*** ORGANIC NET RETURNS ***
* SO 16-01-2025
    results_kom('base',Kommune,"netreturns_org")  = NETRET_ORG.L(Kommune);
    results_kom('base',Kommune,"netreturns_ls")  = NETRET_LS.L(Kommune);
    results_kom('base',Kommune,"netreturns_ls_org")  = NETRET_LS_ORG.L(Kommune);
    results_kom('base',Kommune,"dbha_org")$(total_area(Kommune,'all') AND results_kom('base',Kommune,"organicshare")) = NETRET_ORG.L(Kommune)*100/(results_kom('base',Kommune,"organicshare")*total_area(Kommune,'all'));
    results_kom('base',Kommune,"totalpremium")  = PREM.L(Kommune);
    
*** TOTAL AREA CALCULATIONS ***
* SO 17-01-2025
*    area('base', Kommune,'grassland',type) = sum((Gcrop, Schlag_ID)$type_of_crop(Gcrop, type),CROPPROD.L(Schlag_ID, Gcrop));
*    area('base', Kommune,'arable',type) = sum((Acrop, Schlag_ID)$type_of_crop(Acrop, type),CROPPROD.L(Schlag_ID, Acrop));
*    area('base', Kommune,'all',type) = sum((crop, Schlag_ID)$type_of_crop(crop, type),CROPPROD.L(Schlag_ID, crop));
    area('base', Kommune,'grassland') = sum((crop, Schlag_ID)$(Gcrop(crop) AND Location(Schlag_ID, Kommune)),CROPPROD.L(Schlag_ID, crop));
    area('base', Kommune,'arable') = sum((Acrop, Schlag_ID)$Location(Schlag_ID, Kommune),CROPPROD.L(Schlag_ID, Acrop));
    area('base', Kommune,'all') = sum((crop, Schlag_ID)$Location(Schlag_ID, Kommune),CROPPROD.L(Schlag_ID, crop));
*** CEREAL UNITS ***
* SO 17-01-2025
    results_cu('base', Kommune) = CU.L;

*** NET RETURN PER CROP ***
    results_crop_NR('base', Kommune, "netreturns", crop) = NETRETURN_CROPS.L(Kommune, crop);
    
*** CROP SHARES ***
    results_crop('base', Kommune, crop, 'cultivatedarea') = CROP_KOMMUNE.l(Kommune,crop);
    results_crop('base', Kommune, crop, 'areaincrease')$Landuse_SQ(Kommune,crop)   = (CROP_KOMMUNE.l(Kommune,crop)/Landuse_SQ(Kommune,crop))*100 - 100;
    results_crop('base', Kommune, crop, 'production')    = PRODUCTION_KOM.l(Kommune, crop);
    results_crop('base', Kommune, crop, 'biogas_fodder') = sum(substrate_fodder,FODDER_BIOGAS.l(Kommune, crop, substrate_fodder));
    results_crop('base', Kommune, crop, 'animal_fodder') = sum(ls, FODDER_PROD1.l(Kommune, ls, crop));
    results_crop('base', Kommune, crop, 'sold')          = CROP_SALE.l(Kommune, crop);
    results_crop('base', Kommune, crop, 'bought')        = sum(ls, BOUGHT_FEED.l(Kommune, ls, crop));
    Kom_tot_crop('base', Kommune, kCrop) = CROP_KOMMUNE.L(kommune,kCrop) + SUM(oCrop, map_konv_org(kCrop, oCrop) * CROP_KOMMUNE.L(kommune,oCrop));
    Kom_tot_crop_inc('base',Kommune,kCrop)$Landuse_SQ_crop(Kommune,kCrop) = Kom_tot_crop('base', Kommune, kCrop)/Landuse_SQ_crop(Kommune,kCrop);
    
*** CROP ROTATION ***
    res_precrop_crop('base', Kommune, Schlag_ID, crop, crop2) = Location(Schlag_ID,Kommune) * precrop(Schlag_ID, crop) * CROPPROD.L(Schlag_ID, crop2);
    res_crop_group_share('base', Kommune, cgroup,type)$CULTIV_AREA.L(Kommune,type) = sum(crop$(cropsin(cgroup,crop) and type_of_crop(crop, type)), CROP_KOMMUNE.L(Kommune,crop)) / CULTIV_AREA.L(Kommune,type) * 100;
    vorfruchtwert('base',Kommune,type)$CULTIV_AREA.L(Kommune, type) = sum(Schlag_ID$(Location(Schlag_ID, Kommune) and not GL_ID(Schlag_ID)), sum(crop$type_of_crop(crop, type), CROPPROD.L(Schlag_ID,crop) * sum(crop2, combival_P(crop, crop2)))) / CULTIV_AREA.L(Kommune, type);
    
*** DIVIDED PLOTS ***
    result_divided_plots('base', Schlag_ID) = 1$(smax(crop2,CROPPROD.L(Schlag_ID,crop2)) < Schlag_ha(Schlag_ID));
    count_divided_plots('base') = sum(Schlag_ID,result_divided_plots('base', Schlag_ID));
    
*** PLOT SWITCHES ***              
    result_plot_switch('base',Schlag_ID,Gcrop,crop,'grass_to_org')$(type_of_crop(crop,'org') and type_of_crop(Gcrop,'conv'))
        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
    result_plot_switch('base',Schlag_ID,Gcrop,crop,'grass_to_conv')$(type_of_crop(crop,'conv') and type_of_crop(Gcrop,'org'))
        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
    result_plot_switch('base',Schlag_ID,crop,Gcrop,'conv_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'conv'))
        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
    result_plot_switch('base',Schlag_ID,crop,Gcrop,'org_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'org'))
        = Schlag_ha(Schlag_ID)$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
    ha_plot_switch('base',switch2) = sum((Schlag_ID,crop,crop2),result_plot_switch('base',Schlag_ID,crop,crop2,switch2));
    
    plots_plot_switch('base',Schlag_ID,Gcrop,crop,'grass_to_org')$(type_of_crop(crop,'org') and type_of_crop(Gcrop,'conv'))
        = 1$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
    plots_plot_switch('base',Schlag_ID,Gcrop,crop,'grass_to_conv')$(type_of_crop(crop,'conv') and type_of_crop(Gcrop,'org'))
        = 1$(precrop(Schlag_ID,Gcrop)*modelled_landuse(Schlag_ID,crop));
    plots_plot_switch('base',Schlag_ID,crop,Gcrop,'conv_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'conv'))
        = 1$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
    plots_plot_switch('base',Schlag_ID,crop,Gcrop,'org_to_grassland')$(not Gcrop(crop) and type_of_crop(crop,'org'))
        = 1$(precrop(Schlag_ID,crop)*modelled_landuse(Schlag_ID,Gcrop));
    count_plot_switch('base', switch2) = sum((Schlag_ID, crop, crop2),plots_plot_switch('base',Schlag_ID,crop,crop2,switch2));
    
    plot_count('base') = sum(Schlag_ID$(sum(Kommune,Location(Schlag_ID,Kommune))),1);
    plot_switch_perc('base', switch) = count_plot_switch('base',switch) / plot_count('base');

*** LIVESTOCK NUMBERS AS VARIABLE ***
* MR this section helps to evaluate the effect of livestock numbers set as a variable (LS_PROD)
ls_no_animals('base',Kommune,ls,type) = LS_PROD.L(Kommune, ls, type);
ls_total_animal('base',Kommune) = sum((ls,type),LS_PROD.L(Kommune, ls, type));
ls_total_lsu('base',Kommune) = sum((ls,type),LS_PROD.L(Kommune, ls, type)*ls_unit(ls));
ls_org_share('base',Kommune, ls)$sum(type,LS_PROD.L(Kommune, ls, type)) = LS_PROD.L(Kommune, ls, 'org') / sum(type,LS_PROD.L(Kommune, ls, type));
ls_org_share_tot('base', Kommune)$ls_total_animal('base',Kommune) = sum(ls,LS_PROD.L(Kommune, ls, 'org')) / ls_total_animal('base',Kommune);
ls_yearly_inc('base',Kommune, ls, type)$temp_no_animals(Kommune, ls, type)  = (LS_PROD.L(Kommune, ls, type) - temp_no_animals(Kommune,ls,type)) / temp_no_animals(Kommune, ls, type);
temp_no_animals(Kommune, ls, type) = LS_PROD.L(Kommune, ls, type);

res_lsu('base', Kommune,ls,type) = LS_PROD.l(Kommune, ls, type) * ls_unit(ls);
res_lsu_herb('base', Kommune, type) = sum(ls$ls_herb(ls), LS_PROD.l(Kommune, ls, type) * ls_unit(ls));
res_fodder_area('base', Kommune,type) = sum(fodder_crop$type_of_crop(fodder_crop,type), CROP_KOMMUNE.l(Kommune, fodder_crop));
res_lsu_herb_ha('base',Kommune, type)$res_fodder_area('base',Kommune, type) = res_lsu_herb('base',Kommune, type) / res_fodder_area('base', Kommune, type);
res_bought_feed('base', Kommune, type) = sum((crop, ls)$type_of_crop(crop, type), BOUGHT_FEED.l(Kommune, ls, crop));
res_fodder_prod('base', Kommune, crop) = sum(ls, FODDER_PROD1.L(Kommune,ls,crop));

*** LABOR ***
lab_ls('base',Kommune,timeframe)$lab_avail(Kommune, timeframe) = (sum((ls,type), lab_dem_ls(ls)*LS_PROD.L(Kommune,ls,type)) / 24) / lab_avail(Kommune, timeframe);
lab_crop('base',Kommune,timeframe)$lab_avail(Kommune, timeframe) = sum(Schlag_ID$Location(Schlag_ID,Kommune),
        sum((crop, soil, size)$Schlag_BG(Schlag_ID, soil, size),
            CROPPROD.L(Schlag_ID, crop) * lab_dem(crop, soil, size, timeframe)))
            / lab_avail(Kommune, timeframe);
lab_ls_tot('base',Kommune)$sum(timeframe,lab_avail(Kommune, timeframe)) = sum((ls,type), lab_dem_ls(ls)*LS_PROD.L(Kommune,ls,type)) / sum(timeframe,lab_avail(Kommune, timeframe));
lab_crop_tot('base',Kommune)$sum(timeframe,lab_avail(Kommune, timeframe)) = sum(Schlag_ID$Location(Schlag_ID,Kommune),
        sum((crop, soil, size,timeframe)$Schlag_BG(Schlag_ID, soil, size),
            CROPPROD.L(Schlag_ID, crop) * lab_dem(crop, soil, size, timeframe)))
            / sum(timeframe,lab_avail(Kommune, timeframe));
res_labor1('base', Kommune, timeframe, crop) = LABOR_CROP.l(Kommune, timeframe, crop);
res_labor2('base', Kommune, timeframe, ls, type) = LABOR_LS.l(Kommune, timeframe, ls, type);

*** PLANT NUTRIENT COVERAGE ***
*MR the following section helps to evaluate the availability of organic fertilizer
    area_('base',Kommune,type) = sum(crop$(type_of_crop(crop,type)),CROP_KOMMUNE.l(Kommune,crop));
    result_nutrients('base', Kommune, Duenger, type, 'avail_per_ha')$area_('base',Kommune,type) = ORG_FERT_AVAIL.l(Kommune, Duenger, type) / area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'demand_per_ha')$area_('base',Kommune,type) = sum(crop$type_of_crop(crop,type),PRODUCTION_KOM.l(Kommune,crop)*Duenger_M(crop,Duenger)) / area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'deficit_per_ha') = result_nutrients('base', Kommune, Duenger, type, 'demand_per_ha') - result_nutrients('base', Kommune, Duenger, type, 'avail_per_ha');
    result_nutrients('base', Kommune, Duenger, type, 'deficit_percent')$result_nutrients('base', Kommune, Duenger, type, 'demand_per_ha') = result_nutrients('base', Kommune, Duenger, type, 'deficit_per_ha') / result_nutrients('base', Kommune, Duenger, type, 'demand_per_ha') * 100;
    result_nutrients('base', Kommune, Duenger, type, 'from_R')     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'R', type) - MANURE_CONVERSION_FROM.l(Kommune, 'R', type)) * map_ls_fert('R', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_M')     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'M', type) - MANURE_CONVERSION_FROM.l(Kommune, 'M', type)) * map_ls_fert('M', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_S')     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'S', type) - MANURE_CONVERSION_FROM.l(Kommune, 'S', type)) * map_ls_fert('S', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_H')     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'H', type) - MANURE_CONVERSION_FROM.l(Kommune, 'H', type)) * map_ls_fert('H', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_Eh')    = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'Eh', type) - MANURE_CONVERSION_FROM.l(Kommune, 'Eh', type)) * map_ls_fert('Eh', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_Sch')   = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'Sch', type) - MANURE_CONVERSION_FROM.l(Kommune, 'Sch', type)) * map_ls_fert('Sch', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_Z')     = sum(org_fert,(MANURE_AVAIL.l(Kommune, 'Z', type) - MANURE_CONVERSION_FROM.l(Kommune, 'Z', type)) * map_ls_fert('Z', org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_biogas')= (AMOUNT_BGL.l(Kommune, type) - BGL_CONVERSION_FROM.l(Kommune,type)) * fert_nut_cont('BGL',Duenger) * fert_eff('BGL', Duenger)/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'bought')     = sum(ext_org_fert,FERT_BOUGHT.l(Kommune, ext_org_fert, type) * fert_nut_cont(ext_org_fert,Duenger) * fert_eff(ext_org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_conv_manure')= sum((org_fert, ls), MANURE_CONVERSION_TO.l(Kommune, ls, type) * map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger))/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_conv_biogas')= BGL_CONVERSION_TO.l(Kommune,type) * fert_nut_cont('BGL',Duenger) * fert_eff('BGL', Duenger)/ area_('base',Kommune,type);
    result_nutrients('base', Kommune, Duenger, type, 'from_intercrop')= NUT_FROM_INTERCROP.l(Kommune, Duenger, type);
    result_nutrients('base', Kommune, Duenger, type, 'from_gm_maincrop')= NUT_FROM_GMM.l(Kommune, Duenger, type);

*** BIOGAS PLANTS ***
* MR 17.02.2025 the nutrient ratio of the biogas digestate. should match fert_nut_conten('BGL', Duenger)
nut_cont_biogas('base', Kommune, Duenger, type)$AMOUNT_BGL.l(Kommune, type)=
    (sum((org_fert,ls), sum(substrate_manure,MANURE_BIOGAS.l(Kommune, ls, type, substrate_manure)) * map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, Duenger))
    + sum((crop,substrate_fodder),FODDER_BIOGAS.l(Kommune, crop,substrate_fodder)*Duenger_M(crop, Duenger)*type_of_crop(crop, type)))
    / AMOUNT_BGL.l(Kommune, type);
result_biogas_amount('base', Kommune, type) = AMOUNT_BGL.l(Kommune, type);
result_biogas1('base', Kommune, crop) = sum(substrate_fodder, FODDER_BIOGAS.l(Kommune, crop, substrate_fodder));
result_biogas2('base', Kommune, ls, type) = sum(substrate_manure, MANURE_BIOGAS.l(Kommune, ls, type, substrate_manure));

