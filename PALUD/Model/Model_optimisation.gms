*************************************************************************
*         PALUD (Parcel based agronomic land use decision model)        *
*                                                                       *
*         Model                                                         *
*************************************************************************
* s= ./t/BW_opt r=./t/BW
$INCLUDE filepath.inc


Parameter
prod_cost(Schlag_ID, crop)  Production cost incl. premium for each crop on each plot
fodder_uptake_limit         Factor that limits the maximum share of non-compound feed in animal feed ratios
organic_manure_coverage_lower     lower limit for the share of the demand for organic manure that has to be covered by organic fertilizers
organic_manure_coverage_upper     upper limit for the share of the demand for organic manure that can be covered by organic fertilizers
organic_manure_addition_upper     upper limit for the share of the demand for organic manure that can be covered by organic fertilizers
n_res_violation             Factor to relax the 170 kg N per ha rule
kg_lower_bound              minimum share of clover grass in organic farming
fodder_reserve              Factor by which fodder availabiility needs to exceed fodder demand to account for storage losses and leftover feed
Price_buy(crop)             Buyers prices for crops
fodder_sale_restriction(type) Observed amount of excess feed in dt FM per Livestock unit in the base scenario -> serves es upper limit
gm_intercrop_nutrients      Nutrients obtained by green manure of one hectar of intercropping in kg N P K
gm_maincrop_nutrients       Nutrients obtained by one hectar of green manure as main crop in kg N P K


*** SO: increase organic shares scenario
organic_share_boundary(Kommune,p)  Parameter for updating organic share targets
organic_share_boundary2(p)         Parameter for updating organic share targets at NUTS2 level
* SO: increase fallow land shares scenario
snh_share_boundary
snh_share_boundary_muni(Kommune) Parameter for setting lower bound for snh_share for each municipality
total_area                       total agricultureal area per municipality from Plots_BW
total_area_NUTS3                 total agricultural area per NUTS3 region (LK) from Plots_BW
gm
* SO 07.08.2025: Price reduction of organic
Price_new(crop)                  New Price for organic crops_ top-up reduced by factor 
;

* Default settings
$if not set corridor_crop_change $set corridor_crop_change 0.66
$if not set corridor_grass_change $set corridor_grass_change 0.2
$if not set corridor_combined_crop_change $set corridor_combined_crop_change 0.05
$if not set corridor_combined_bcrop_change $set corridor_combined_bcrop_change 0.05
$if not set corridor_livestock_change $set corridor_livestock_change 0.2
$if not set corridor_combined_livestock_change $set corridor_combined_livestock_change 0.05
$if not set org_increase_lower $set org_increase_lower 0.73
$if not set org_increase_upper $set org_increase_upper 0.73
$if not set snh_increase $set snh_increase 0
$if not set prem_OF $set prem_OF 240
$if not set prem_SNH $set prem_SNH 650
$if not set of_price_red_factor $set of_price_red_factor 1
$if not set snh_offset_param $set snh_offset_param 0.5
$if not set yield_gap_sens $set yield_gap_sens 0

Scalar
corridor_crop_change_halfwidth  allows a +- xx (*100) percent change of the cultivated area for each crop per year																																	
/%corridor_crop_change%/
corridor_grass_change_halfwidth allows a +- xx (*100) percent change of the cultivated area for grassland per year                                                                                                                                  
/%corridor_grass_change%/
snh_offset_param                Parameter for determinung what percentange of the snh increase can be offset to other municipalities
/%snh_offset_param%/
yield_gap_sens                  Parameter for sensitivity analysis on organic yield gaps
/%yield_gap_sens%/
*/0.1/
* 0.16 for 40% in 2030
* 0.15 for 35% in 2030
* 0.12 for 30% in 2030
* 0.1 for 25% in 2030
* 0.1 for BAU
corridor_combined_crop_change_halfwidth  half size of the corridor in which the total area of organic and conventional croparea can be changed each year for each crop
/%corridor_combined_crop_change%/
corridor_combined_bcrop_change_halfwidth half size of the corridor in which the total area of organic and conventional fallow land and SNH can be changed each year for each crop
/%corridor_combined_bcrop_change%/
*/.03/
corridor_livestock_change_halfwidth  allows a +- xx (*100) percent change of the number of each livestock category and type per year
/%corridor_livestock_change%/
*/.1/
corridor_combined_livestock_change_halfwidth  half size of the corridor in which the total number of organic and conventional livestock units can be changed each year for each livestock category
/%corridor_combined_livestock_change%/
*/.03/																																														  	  
trans_cost_conversion           transaction cost for internal nutrient conversion in % of the price
/0.1/
intercrop_cost                  cost per ha of intercropping (taken from KTBL 2025 'Zwischenfrucht Luzerne')
/290/
org_share_increase_lower
/%org_increase_lower%/
* +3.3 for 40% in 2030
* +2.75 for 35% in 2030
* +2.2 for 30% in 2030
* +1.64 for 25% in 2030
* for BAU
* /0.73/
org_share_increase_upper
/%org_increase_upper%/
* 0.73 for BAU
snh_share_increase
/%snh_increase%/
slack_OF
/0.05/
slack_SNH
/0.01/
of_price_red_factor
/%of_price_red_factor%/
;

* SO 21-11-2025: Yield gap sensitivity analysis
Yield(ocrop, soil, size) = min(max(Yield(ocrop, soil, size), sum(kcrop, Yield(kcrop, soil, size)*map_konv_org(kcrop, ocrop))),(1+yield_gap_sens)*Yield(ocrop, soil, size));

* SO 14-08-2025: New price for OF with reduced OF price premium
Price_new(crop) = max(K_Price(crop), K_Price(crop)+(of_price_premium(crop)*of_price_red_factor));
Price_buy(crop) = Price_new(crop);  

*MR 28-03-24 premium for continous organic farming in BaWue according to FAKT II
Premium_OF(oCrop) = %prem_OF%;
* SO 15-08-2025: To explore under which cicumstances OF on grassland would become less profitable
* -> even if prices are the same as for conventional farming and no premium for organic grassland, OF on grassland would still rise to >70% without corridors
*Premium_OF(Gcrop) = 0;
Premium_OF(Bcrop) = 0;
Premium_SNH("BL") = %prem_SNH%;
Premium_SNH("oBL") = %prem_SNH%;
* SO 2025-05-26 TODO: Ist dies bereits raus genommen? -> Ja
*fodder_sale_restriction('conv') = 16;
*fodder_sale_restriction('org') = 96;

* SO 2025-05-26: Ggf. Mittelwerte genommen
* source: LfL Wirkung von Zwischenfrüchten:
gm_intercrop_nutrients('N') = 24;
* source: Kolbe & Köhler 2008 - Tabelle 16: Luzerne, Serradella u.  Esparsette 216 kg N/ha mit 20% Gesamtwirksamkeit (216 kg N/ka * 0.2)
gm_maincrop_nutrients('N') = 43.2;


* SO 25-09-2024
total_area(Kommune,'all') = sum(type, total_area_SQ(Kommune,'all',type));
total_area(Kommune,'arable') = sum(type, total_area_SQ(Kommune,'arable',type));
total_area(Kommune,'grassland') = sum(type, total_area_SQ(Kommune,'grassland',type));
* SO 14-07-2025
total_area_NUTS3('all') = sum (Kommune, total_area(Kommune, 'all'));
total_area_NUTS3('arable') = sum (Kommune, total_area(Kommune, 'arable'));
total_area_NUTS3('grassland') = sum (Kommune, total_area(Kommune, 'grassland'));

organic_share_boundary(Kommune,'all') = 0;
organic_share_boundary2('all') = 0;								   

* SO 26-06-2025
snh_share_boundary = 0;
snh_share_boundary_muni(Kommune) = 0;

organic_manure_coverage_lower(Duenger) = 0.8;
organic_manure_coverage_lower('N') = 1;

* So 02-06-2025: OLD VERSION
*organic_manure_coverage_upper(Duenger) = 1.2;
*organic_manure_coverage_upper('N') = 1.1;

* SO 02-06-2025: NEW VERSION
organic_manure_addition_upper('N') = 1;
organic_manure_addition_upper('P') = 14;
organic_manure_addition_upper('K') = 100;


fodder_uptake_limit = 1.2;
n_res_violation = 1;
fodder_reserve = 1;
kg_lower_bound = 0.15;


prod_cost(Schlag_ID, crop)  = sum((soil, size)$Schlag_BG(Schlag_ID, soil, size),
                                0
                                -Fertilizer(crop, soil, size)
                                -Pest_cost(crop, soil, size)
                                -Seeds(crop, soil, size)
                                -Repair(crop, soil, size)
                                -(Diesel(crop, soil, size)*Diesel_P)
                                -wages(crop, soil, size)
                                -drying(crop, soil, size)
                                -other_costs(crop, soil, size))
                                 ;
   
prod_cost(Schlag_ID, ocrop) = prod_cost(Schlag_ID, ocrop)*(1+(yield_gap_sens/2));
                        
* MR 27-01-25 calculate gross margin (without premium) just to check
gm(Kommune,crop, soil, size) =
    (Yield(crop, soil, size) * Price(crop))$(Acrop(crop))

    + (Yield(crop, soil, size) * Dgr_yield(Kommune) / dry_matter_content(crop))$(Gcrop(crop))

                                -Fertilizer(crop, soil, size)
                                -Pest_cost(crop, soil, size)
                                -Seeds(crop, soil, size)
                                -Repair(crop, soil, size)
                                -(Diesel(crop, soil, size)*Diesel_P)
                                -wages(crop, soil, size)
                                -drying(crop, soil, size)
                                -other_costs(crop, soil, size);

****************************
*** Optimisation of land use
****************************

$include utility_functions\set_model_variables.gms

    
$include utility_functions\set_model_equations.gms
    

*************************
*  MINIMAL CONSTRAINTS  *
*************************

Objf..
   NETRETURN
   =e=
   sum(Kommune,NETRETURN_MUNI(Kommune));
        
* This equation calculates the net return per municipality
netret_muni(Kommune)..
   NETRETURN_MUNI(Kommune)
   =e=
* production cost (negative value)								  
  sum((Schlag_ID, crop)
  $(Location(Schlag_ID, Kommune) and prod_cost(Schlag_ID, crop)),
    prod_cost(Schlag_ID, crop)*CROPPROD(Schlag_ID, crop))
        
  + sum((crop),CROP_SALE(Kommune,crop)*Price_new(crop))
* MR minus the money needed to buy external feed
  - sum((ls,crop),BOUGHT_FEED(Kommune,ls,crop)*
    Price_buy(crop) *transport_fee)

* MR fertilization with manure in conventional farming: refund of fertilization cost  (not in organic because there are no fertilization cost in the first place)
  + sum(Duenger, ORG_FERT_AVAIL(Kommune, Duenger, 'conv') * Duenger_P(Duenger))

* MR 19-07-24 income from livestock  
  + NETRET_LS(Kommune)
  
* MR 24-01-25 plus premium (was before incorporated in prod_cost, but now removed there)
  + PREM_OF(Kommune) + PREM_SNH(Kommune)
* MR 25.11.24 income from manure trade
  + sum((type, ls, org_fert),(DUENGER_SOLD(Kommune, ls, type)* map_ls_fert(ls, org_fert) * fert_price(org_fert)))

* MR 18.02.2025 cost for organic fertilizer
  - sum(type, ORG_FERT_COST(Kommune, type))																																					
;

    
* MR 19.11.24 calculate the Netreturn of livestock production
netret_ls_eq(Kommune)..
    NETRET_LS(Kommune)																 														   
    =e=
    sum((ls,type),LS_PROD(Kommune,ls,type)*Ls_gm(ls,type));
	
	
*MR 12-04-24 calculates the crop production (yield) per region in dt
yield_kommune(Kommune,crop)..
    PRODUCTION_KOM(Kommune, crop)
    =e=
* The amount that is produced, but not harvested because it is incorporated into the soil as green manure has to be substracted (only for valid GreenManure crops)
    (sum((Schlag_ID)$Location(Schlag_ID,Kommune),
        (CROPPROD(Schlag_ID,crop) - GM_MAINCROP(Schlag_ID, crop)) *
        sum((soil,size)$Schlag_BG(Schlag_ID,soil, size),
        (Yield(crop, soil, size)*sum(crop2$(precrop(Schlag_ID,crop2)),0.15 + combival_P(crop2,crop)*.1))))) $ (Acrop(crop))
*  SO 11.07.2025: OLD:
*          (Yield(crop, soil, size)*sum(crop2$(precrop(Schlag_ID,crop2)),0.346 + combival_P(crop2,crop)/13))))) $ (Acrop(crop))

    + (sum((Schlag_ID)$Location(Schlag_ID,Kommune),
        CROPPROD(Schlag_ID,crop) *
        sum((soil,size)$Schlag_BG(Schlag_ID,soil, size),
        Yield(crop, soil, size) * Dgr_yield(Kommune) / dry_matter_content(crop)))) $ (Gcrop(crop));



yield_distribution(Kommune,crop)..
    PRODUCTION_KOM(Kommune, crop)						 		
    =e=																		  
    CROP_SALE(Kommune, crop) 
	+ sum(ls,FODDER_PROD1(Kommune,ls,crop)) 
	+ sum(substrate_fodder,FODDER_BIOGAS(Kommune, crop, substrate_fodder));


* plot sizes cannot be exeeded for each plot
Area_res(Schlag_ID)..
    sum(crop, CROPPROD(Schlag_ID, crop))
         =e=
       Schlag_ha(Schlag_ID);
	   
Sum_crop(Kommune, crop)..
        sum(Schlag_ID$Location(Schlag_ID, Kommune), CROPPROD(Schlag_ID, crop))
        =e=
        CROP_KOMMUNE(Kommune, crop);									
		
*MR 12-08-2024 on permanent grassland, only permanent grassland is valid.
GL_Area_res(Schlag_ID)$(not arable_land(Schlag_ID))..
    sum(Acrop, CROPPROD(Schlag_ID, Acrop))
    =e= 0;

* SO 19-01-2025 on arable land, only arable crops are valid
AL_Area_res(Schlag_ID)$arable_land(Schlag_ID)..
    sum(Gcrop, CROPPROD(Schlag_ID, Gcrop))
    =e= 0;

* Calculate total organic premium in the municipality for continous organic farming
premium_of_eq(Kommune)..																							 
    sum((crop, Schlag_ID)$Location(Schlag_ID, Kommune), Premium_OF(crop)*CROPPROD(Schlag_ID, crop))										 
    =e=
    PREM_OF(Kommune);

premium_snh_eq(Kommune)..
    sum((crop, Schlag_ID)$Location(Schlag_ID, Kommune), Premium_SNH(crop)*CROPPROD(Schlag_ID, crop))
    =e=
    PREM_SNH(Kommune);
   
* MR 25-03-2025 When BIOGAS PLANT module is not included in the model, the available biogas digestate amount is zero
no_biogas_plant..
    sum((Kommune, type), AMOUNT_BGL(Kommune, type))
    =e=
    0;
	
* MR 26-03-2025 When ORGANIC NUTRIENT CONSTRAINTS are not included int he model, ORG_FERT_AVAIL has to be set to 0
																									 
no_org_fert..
    sum((Kommune, Duenger, type), ORG_FERT_AVAIL(Kommune, Duenger, type))
    + sum((Kommune, ls, type), DUENGER_SOLD(Kommune, ls, type) + DUENGER_BOUGHT(Kommune, ls, type))
    =e=																						  
    0;	
	
	

***************************** 
*  ADDITIONAL CALCULATIONS  *
*****************************     

* SO 16-11-2025: Calculate cereal units
CU_eq(Kommune)..
   sum((Schlag_ID, crop)$Location(Schlag_ID, Kommune),
   CROPPROD(Schlag_ID, crop)*cereal_unit(Schlag_ID, crop))
   =e=
   CEREAL_UNITS(Kommune);


* SO 16-01-2025: Calculate Net return per crop (prodution costs - sale). does not inculde organic fertilizer (because it is not crop specific)
netret_crops_eq(Kommune, crop)..
   NETRETURN_CROPS(Kommune, crop)
   =e=
  sum(Schlag_ID$(Location(Schlag_ID, Kommune) and prod_cost(Schlag_ID, crop)),
    prod_cost(Schlag_ID, crop)*CROPPROD(Schlag_ID, crop))
  + PRODUCTION_KOM(Kommune, crop)*Price_new(crop);


* SO 16-01-2025: Calculate Net return of organic farming (without premium)
netret_org_eq(Kommune)..
    NETRET_ORG(Kommune)
    =e=
    sum((Schlag_ID, ocrop)
  $(Location(Schlag_ID, Kommune) and prod_cost(Schlag_ID, ocrop)),
    prod_cost(Schlag_ID, ocrop)*CROPPROD(Schlag_ID, ocrop))
        
* MR 19-04-2024 minus the revenue for the crop needed to feeed the animals (we want to feed animals cheap)
  + sum((ocrop),CROP_SALE(Kommune,ocrop)*Price_new(ocrop))
* MR minus the money needed to buy external feed
  - sum((ls,ocrop),BOUGHT_FEED(Kommune,ls,ocrop)*Price_new(ocrop)*transport_fee)

* MR 19-07-24 income from livestock  
  + NETRET_LS_ORG(Kommune)


* MR 25.11.24 income from manure trade
  + sum((type, ls, org_fert),(DUENGER_SOLD(Kommune, ls, type)* map_ls_fert(ls, org_fert) * fert_price(org_fert)))

* MR 18.02.2025 cost for organic fertilizer
  - sum(type, ORG_FERT_COST(Kommune, 'org'))
;

* SO 16-01-2025: Calculate Net return of organic livestock farming 
netret_ls_org_eq(Kommune)..
    NETRET_LS_ORG(Kommune)
    =e=
    sum((ls),LS_PROD(Kommune,ls,"org")*Ls_gm(ls,"org"))
;


*****************************
*  PREVENT EXTREME CHANGES  *
***************************** 
     
* SO 03-12-2024 
* Include restriction for change org <-> conv in grassland.
SQ_Kommune_GL(Kommune, GHMcrop)..
         CROP_KOMMUNE(Kommune, GHMcrop) +
         SUM(GSMcrop, map_GHM_GSM(GHMcrop, GSMcrop)*CROP_KOMMUNE(Kommune, GSMcrop))
         =l=
         Landuse_SQ_GL(Kommune, GHMcrop)*(1+corridor_grass_change_halfwidth);


* SO 16-01-2025: Add Landuse_SQ to the condition so that it is allowed to introduce a new crop in the municipality
* SO 16.07.2025: Changed right hand side of this equation. 
*SQ_Kommune(Kommune, crop)$(Landuse_SQ(Kommune, crop) AND not GHMcrop(crop) AND not GSMcrop(crop) AND not Bcrop_arable(crop))..
*         CROP_KOMMUNE(Kommune, crop)
*         =l=
*         (sum(crop2, map_konv_org_all(crop, crop2) * Landuse_SQ(Kommune, crop2)) + Landuse_SQ(Kommune, crop))*(1+0.05);
* SO 16.07.2025: Old:
SQ_Kommune_upper(Kommune, crop)$(Landuse_SQ(Kommune, crop) AND not GHMcrop(crop) AND not GSMcrop(crop) AND not BLcrop(crop))..
* For SNH scenario: AND not Bcrop_arable(crop))..
         CROP_KOMMUNE(Kommune, crop)
         =l=
         Landuse_SQ(Kommune, crop)*(1+corridor_crop_change_halfwidth);


*SQ_Kommune_lower(Kommune, crop)$(Landuse_SQ(Kommune, crop) AND not GHMcrop(crop) AND not GSMcrop(crop) AND not Bcrop_arable(crop))..
*         CROP_KOMMUNE(Kommune, crop)
*         =l=
*         (sum(crop2, map_konv_org_all(crop, crop2) * Landuse_SQ(Kommune, crop2)) + Landuse_SQ(Kommune, crop))*(1-0.05);
* SO 16.07.2025: Right hand side old:
SQ_Kommune_lower(Kommune, crop)$(Landuse_SQ(Kommune, crop) AND not GHMcrop(crop) AND not GSMcrop(crop) AND not BLcrop(crop))..
* For SNH scenario: AND not Bcrop_arable(crop))..
         CROP_KOMMUNE(Kommune, crop)
         =g=
         Landuse_SQ(Kommune, crop)*(1-corridor_crop_change_halfwidth);
   
   
* SO 16-01-2025: If a new crop is introduced in the municipality (e.g. oWR if previously only WR was available), a maximum of 5% can initially be converted.
*SQ_Kommune_ini(Kommune, crop)$(not Landuse_SQ(Kommune, crop) AND not GHMcrop(crop) AND not GSMcrop(crop))..
*         CROP_KOMMUNE(Kommune, crop)
*         =l=
*         5;
*  
       
SQ_Kommune_ini(Kommune, ocrop)$(not Landuse_SQ(Kommune, oCrop)AND not GHMcrop(ocrop) AND not GSMcrop(ocrop))..
* For SNH scenario: AND not Bcrop_arable(ocrop))..
         CROP_KOMMUNE(Kommune, ocrop)
         =l=
         sum(kCrop, map_konv_org(kCrop, oCrop) *Landuse_SQ_crop(Kommune, kCrop)*0.05);


* SO 16-01-2025: This equation is added in addition to SQ_Kommune_ini to prevent new conventional crops from being introduced
SQ_Kommune_ini2(Kommune, kcrop)$(not Landuse_SQ_crop(Kommune, kCrop)AND not GHMcrop(kcrop) AND not GSMcrop(kcrop) AND not BLcrop(kcrop))..
* For SNH scneario: AND not Bcrop_arable(kcrop))..
         CROP_KOMMUNE(Kommune, kcrop)
         =e= 0;
*         =l=
*         Landuse_SQ_crop(Kommune, kCrop);
   
   
*MR 19-07-2024 The model cannot change the total production area (org + conv) of one crop by more than 2%
* SO 31.07.2025: Hier würde ich eigentlich für BAU & OF Szenario den Zusatz "AND not BLcrop(kcrop)" rausnehmen wollen, weil ich ja kontrastrierende Szenarien
* ohne übermäßigen Ausbau von SNH (= BL & oBL) simulieren möchte. Allerdings wird das Modell dann immer infeasible. Auch ohne Labor contraints.
* In results_SNH_share_detailed_NUTS3 sehen wir einen extrem hohen Anstieg für oBL in 2022 und 2023 (danach eingependelt). In die Berechnung vom
* organic share wird Brache & Blühfläche nicht berücksichtigt. Es liegt also nicht daran, dass mit oBL das Ziel für den Ökolandbau einfach zu
* erfüllen ist. Die Gründe müssen also anderswo liegen (Vermutung: Nährstoffbilanz/Dünger).
* Woran kann das liegen? Vermutung: Nicht genug Dünger für Ökolandbau, da Tierzahlen auch schrumpfen. Allerdings exisitert das Problem auch mit
* Fix_Livestock_to_SQ...
SQ_crop_upper(Kommune,kCrop)$(not GHMcrop(kcrop) AND not GSMcrop(kcrop) AND not SNH(kcrop))..
* For SNH scneario: AND not Bcrop_arable(kcrop))..
        CROP_KOMMUNE(Kommune,kCrop) + SUM(oCrop, map_konv_org(kCrop, oCrop) * CROP_KOMMUNE(Kommune,oCrop))						   
        =l=
        Landuse_SQ_crop(Kommune,kCrop)*(1+corridor_combined_crop_change_halfwidth);
        
* SO 31.07.2025: Hier habe ich jetzt ebenso den Zusatz hinzugefügt, um konsistent zu sein. Das untere Limit sollte aber eigentlich keine
* Probleme bereiten.
SQ_crop_lower(Kommune,kCrop)$(not GHMcrop(kcrop) AND not GSMcrop(kcrop) AND not SNH(kcrop))..

        CROP_KOMMUNE(Kommune,kCrop) + SUM(oCrop, map_konv_org(kCrop, oCrop) * CROP_KOMMUNE(Kommune,oCrop))
        =g=
        Landuse_SQ_crop(Kommune,kCrop)*(1-corridor_combined_crop_change_halfwidth);
        
SQ_bcrop_upper(Kommune,kCrop)$(SNH(kcrop))..
        CROP_KOMMUNE(Kommune,kCrop) + SUM(oCrop, map_konv_org(kCrop, oCrop) * CROP_KOMMUNE(Kommune,oCrop))                         
        =l=
        (Landuse_SQ_crop(Kommune,kCrop)+SUM(oCrop, map_konv_org(kCrop, oCrop)* Landuse_SQ_crop(Kommune,oCrop))) *(1+corridor_combined_bcrop_change_halfwidth);
        
* constraining the livestock change within a certain corridor    
SQ_Livestock_res_upper(Kommune, ls, type)$Livestock_SQ(Kommune, ls,type)..
    LS_PROD(Kommune, ls, type)
								
    =l=
    Livestock_SQ(Kommune, ls, type)*(1 + corridor_livestock_change_halfwidth);

SQ_Livestock_res_lower(Kommune, ls, type)$Livestock_SQ(Kommune, ls,type)..								 
    LS_PROD(Kommune, ls, type)
    =g=
    Livestock_SQ(Kommune, ls, type)*(1 - corridor_livestock_change_halfwidth);																							
    
*SO 20-01-2025 The model cannot change the total production (org + conv) of one livestock category by more than 2% p.a.
SQ_Livestock_upper(Kommune,ls)..
        sum(type, LS_PROD(Kommune,ls, type))
        =l=
        sum(type, Livestock_SQ(Kommune,ls, type))*(1 + corridor_combined_livestock_change_halfwidth);

SQ_Livestock_lower(Kommune,ls)..
        sum(type, LS_PROD(Kommune,ls, type))
        =g=
        sum(type, Livestock_SQ(Kommune,ls, type))*(1 - corridor_combined_livestock_change_halfwidth);
  
* SO 14-07-2025: Allow new livestock units to be introduced in a municipality at a marginal level
*                (especially important for municipalities with very low organic percentage shares (<2perc), for which we set livestock to 0)

SQ_Livestock_ini(Kommune, ls, type)$(not Livestock_SQ(Kommune, ls, type))..
         LS_PROD(Kommune, ls, type)
         =l=
         sum(type1, type_unequal(type, type1) *Livestock_SQ(Kommune, ls, type1)*0.05);

**************************
*  SET ASIDE CONSTRAINT  *
**************************							 
* Set-aside area is greater or equal the status quo set-aside area
set_aside(Kommune,kCrop)$(Bcrop(kcrop))..
        CROP_KOMMUNE(Kommune,kCrop) + SUM(oCrop, map_konv_org(kCrop, oCrop) * CROP_KOMMUNE(Kommune,oCrop))                         
        =g=
        Landuse_SQ_base(Kommune, kcrop);
*set_aside(Kommune, Bcrop)..
*     CROP_KOMMUNE(Kommune, Bcrop)
*     =g=
*    Landuse_SQ_base(Kommune, Bcrop);
    
**************************** 
*  SIMULATE BASELINE YEAR  *
**************************** 

baseline(Schlag_ID, crop)..
        CROPPROD(Schlag_ID, crop)
        =e=
        precrop(Schlag_ID, crop) * Schlag_ha(Schlag_ID);	
		
Fix_Livestock_to_SQ(Kommune, ls, type)..
    LS_PROD(Kommune, ls, type)
    =e=
    Livestock_SQ(Kommune, ls, type);
	

*MR 12-04-24 calculates the crop production (yield) per Kommune in dt
*Q: SO 19-01-2025: Can we add a second equation here that calculates PRODUCTION_KOM (& Further net returns) for baseline?
* SO 25-06-2025: Add yield calculation for baseline simply with PRODUCTION_KOM =prop. to yield
yield_kommune_base(Kommune, crop)..
    PRODUCTION_KOM(Kommune, crop)
    =e=
        (sum((Schlag_ID)$Location(Schlag_ID,Kommune),
            (CROPPROD(Schlag_ID,crop) - GM_MAINCROP(Schlag_ID, crop)) *
            sum((soil,size)$Schlag_BG(Schlag_ID,soil, size),
                (Yield(crop, soil, size)))))$(Acrop(crop))
        +
        (sum((Schlag_ID)$Location(Schlag_ID,Kommune),
        CROPPROD(Schlag_ID,crop) *
        sum((soil,size)$Schlag_BG(Schlag_ID,soil, size),
        Yield(crop, soil, size) * Dgr_yield(Kommune) / dry_matter_content(crop)))) $ (Gcrop(crop));;
	
	
************************************************
*  ORGANIC CROP NUTRIENT COVERAGE CONSTRAINTS  *
************************************************
*MR 10-04-24 for organic crops the nutrient demand has to be covered with organic fertilizer
manure_res_lower(Kommune, Duenger)..
    ORG_FERT_AVAIL(Kommune, Duenger, 'org')
    =g=
    organic_manure_coverage_lower(Duenger) * sum((oCrop),
    PRODUCTION_KOM(Kommune,oCrop) * Duenger_M(oCrop, Duenger));


* calculation of the available organic fertilizer per Kommune
org_fert_eq(Kommune, Duenger, type)..
    ORG_FERT_AVAIL(Kommune, Duenger, type)
    =e=
    sum(ls, NUT_FROM_MANURE(Kommune, Duenger, ls, type))
    + NUT_FROM_BIOGAS(Kommune, Duenger, type)
    + NUT_FROM_EXT(Kommune, Duenger, type)
    + NUT_FROM_INTERCROP(Kommune, Duenger, type)
    + NUT_FROM_GMM(Kommune, Duenger, type);


**** (1/5) Component of ORG_FERT_AVAIL: MANURE

nut_manure_eq(Kommune, Duenger, ls, type)..
    NUT_FROM_MANURE(Kommune, Duenger, ls, type)
    =e=
    sum(org_fert, (MANURE_AVAIL(Kommune, ls, type) + MANURE_CONVERSION_TO(Kommune, ls, type) - MANURE_CONVERSION_FROM(Kommune, ls, type)) * map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, Duenger) * fert_eff(org_fert, Duenger));

* the manure available for crop fertilization is the amount of manure produced by the livestock minus the manure used as biogas input       								
manure_avail_eq(Kommune, ls, type)..
    MANURE_AVAIL(Kommune, ls, type) + sum(substrate_manure,MANURE_BIOGAS(Kommune, ls, type, substrate_manure))
    =e=
    (LS_PROD(Kommune, ls, type) * manure_prod(ls)) 
	- DUENGER_SOLD(Kommune, ls, type) + DUENGER_BOUGHT(Kommune, ls, type);
    
* MR 17.02.2025
* Restrictions for use of organic fertilizer
conversion_res1(Kommune, type, type1)..
    sum(ls,MANURE_CONVERSION_TO(Kommune, ls, type)) * type_unequal(type, type1)
    =e=
    sum(ls, MANURE_CONVERSION_FROM(Kommune, ls, type1)) * type_unequal(type, type1);


**** (2/5) Component of ORG_FERT_AVAIL: BIOGAS DIGESTATE    
* is zero if no_biogas_plant because then AMOUNT_BGL = 0	
 nut_biogas_eq(Kommune, Duenger, type)..
    NUT_FROM_BIOGAS(Kommune, Duenger, type)
    =e=
    (AMOUNT_BGL(Kommune, type) + BGL_CONVERSION_TO(Kommune, type) - BGL_CONVERSION_FROM(Kommune,type)) * fert_nut_cont('BGL',Duenger) * fert_eff('BGL', Duenger);

biogas_conversion_res(Kommune,type)..
    BGL_CONVERSION_FROM(Kommune, type)
    =l=
    AMOUNT_BGL(Kommune, type);
	
conversion_res2(Kommune, type, type1)..
    BGL_CONVERSION_TO(Kommune, type) * type_unequal(type, type1)
    =e=
    BGL_CONVERSION_FROM(Kommune, type1) * type_unequal(type, type1);
	
	
*** (3/5) Component of ORG_FERT_AVAIL: BOUGHT/EXTERNAL FERTILIZER	
nut_ext_eq(Kommune, Duenger, type)..
    NUT_FROM_EXT(Kommune, Duenger, type)
    =e=
    sum(ext_org_fert,FERT_BOUGHT(Kommune, ext_org_fert, type) * fert_nut_cont(ext_org_fert,Duenger) * fert_eff(ext_org_fert, Duenger));
    
* bought_fertilizer_res: constrains the maximum amount of manure and biogas digestate that can be transferred from conventional to organic
* the constraint is in terms of kg N per ha 
* Regulations according to BIOLAND standards (Germany's largest organic farming association)
* upper limit for bought fertilizer: 40 kg N/ha for cropping and grassland and 110 kg N/ha for vegetable production    
bought_fertilizer_res(Kommune)..
    sum((ls,org_fert), MANURE_CONVERSION_TO(Kommune, ls, 'org')*map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, 'N'))
    + BGL_CONVERSION_TO(Kommune,'org') * fert_nut_cont('BGL','N')
    + sum(ext_org_fert,FERT_BOUGHT(Kommune, ext_org_fert, 'org') * fert_nut_cont(ext_org_fert,'N'))
    =l=
    40 *  sum(oCrop$(not vegetable(oCrop)),CROP_KOMMUNE(Kommune, oCrop))
    + 110 * sum(oCrop$(vegetable(oCrop)),CROP_KOMMUNE(Kommune, oCrop));


*** (4/5) Component of ORG_FERT_AVAIL: INTERCROPPING   

nut_intercrop_eq(Kommune, Duenger, type)..
    NUT_FROM_INTERCROP(Kommune, Duenger, type)
    =e=
    GM_INTERCROP_HA(Kommune,type) * gm_intercrop_nutrients(Duenger);

* gm_intercrop_res: intercropping is only possible before a spring crop
gm_intercrop_res(Kommune,type)..
    GM_INTERCROP_HA(Kommune,type)
    =l=
    sum(crop$(springcrop(crop) and type_of_crop(crop, type)), CROP_KOMMUNE(Kommune,crop));


*** (5/5) Component of ORG_FERT_AVAIL: GREEN MANURE AS MAIN CROP

nut_gmm_eq(Kommune, Duenger, type)..
    NUT_FROM_GMM(Kommune, Duenger, type)
    =e=
    sum(gmcrop,sum(Schlag_ID$Location(Schlag_ID,Kommune),GM_MAINCROP(Schlag_ID,gmcrop))*type_of_crop(gmcrop,type)) * gm_maincrop_nutrients(Duenger);

* only gmcrops (KG and oKG) can be used as green manure
gm_maincrop_res(Schlag_ID, crop)..
    GM_MAINCROP(Schlag_ID,crop)
    =l=
    CROPPROD(Schlag_ID,crop) * gmcrop(crop);
	
	
*** Equations to restrict overfertilization 


* SO 02-06-2025 OLD VERSION    
*manure_res_upper(Kommune, Duenger, type)..
*    ORG_FERT_AVAIL(Kommune, Duenger, type)
*    =l=
*    organic_manure_coverage_upper(Duenger) * sum(crop$type_of_crop(crop,type),
*    PRODUCTION_KOM(Kommune,crop) * Duenger_M(crop, Duenger));
   
* SO 02-06-2025 NEW VERSION
* MR: Beschränkung von Überdüngung.
* Gemäß Gesetzlicher Regelung früher max 20., jetzt max. 10 kg P pro ha über Bedarf. Bei K keine Beschränkung.
* Die Grenze sind 14 kg P weil die SQ Daten für ein paar Landkreise weniger nicht hergegeben haben (wie gesagt, früher war die Grenze höher)
 
*manure_res_upper(Kommune, Duenger, type)..
*    ORG_FERT_AVAIL(Kommune, Duenger, type)
*    =l=
*    organic_manure_addition_upper(Duenger) * sum(crop$type_of_crop(crop,type),
*    PRODUCTION_KOM(Kommune,crop) * Duenger_M(crop, Duenger));
    
manure_res_upper(Kommune, Duenger, type)..
    ORG_FERT_AVAIL(Kommune, Duenger, type)
    =l=
    organic_manure_addition_upper(Duenger) * sum(crop$type_of_crop(crop,type),CROP_KOMMUNE(Kommune, crop))
    + sum(crop$type_of_crop(crop, type), PRODUCTION_KOM(Kommune, crop) * Duenger_M(crop, Duenger));
    

n_res(Kommune,type)..
    ORG_FERT_AVAIL(Kommune, 'N', type)
    =l=
    170 * n_res_violation * sum(crop$(type_of_crop(crop,type)),CROP_KOMMUNE(Kommune,crop));
	
* MR 18.02.25 cost for organic fertilizers: does not include the cost for green manure as a main crop
org_fert_cost_eq(Kommune, type)..
    ORG_FERT_COST(Kommune, type)			 
    =e=
* MR 25.11.24 cost of manure trade
    sum((ls, org_fert),DUENGER_BOUGHT(Kommune, ls, type)* map_ls_fert(ls, org_fert) * fert_price(org_fert)*transport_fee)
* MR 18.02.25 cost for intercropping
    + (GM_INTERCROP_HA(Kommune,type) * intercrop_cost)
* MR 18.02.25 cost for bought organic fertilizer (external)
    + sum(ext_org_fert, FERT_BOUGHT(Kommune, ext_org_fert, type) * fert_price(ext_org_fert))
* MR 18.02.25 transaction cost for internal nutrient conversion
    + (sum((ls,org_fert),MANURE_CONVERSION_TO(Kommune, ls, type) * map_ls_fert(ls, org_fert) * fert_price(org_fert))
                + BGL_CONVERSION_TO(Kommune, type) * fert_price('BGL')) * trans_cost_conversion
;
        
* Distinguish Manure_avail (for crop production) and Manure for biogas production    
duenger_trade_res(NUTS3, ls, type)..
    sum(Kommune$Location_Kom(Kommune, NUTS3), DUENGER_BOUGHT(Kommune, ls, type))							   
    =e=
    sum(Kommune$Location_Kom(Kommune, NUTS3), DUENGER_SOLD(Kommune, ls, type));

*duenger_trade_res2(Kommune, ls, type)..
*    DUENGER_SOLD(Kommune, ls, type)																						
*    =l=
*    MANURE_AVAIL(Kommune, ls, type) + DUENGER_BOUGHT(Kommune, ls, type);								
**********************************
*  LIVESTOCK FEED DEMAND MODULE  *
**********************************    
fodder_dem_eq(Kommune, ls, type, comp)..
    FODDER_DEM(Kommune, ls, type, comp)
					
    =e=
    LS_PROD(Kommune, ls, type) * Ls_dem(ls, comp) * 365;																											

* the animal fodder demand has to be covered either by bought feed or by produced crops    
fodder_dem_res(Kommune,type,comp,ls)..
    FODDER_DEM(Kommune,ls,type,comp)*fodder_reserve
    =l=
    sum((crop)$max_share(crop,ls),(FODDER_PROD1(Kommune,ls,crop) + BOUGHT_FEED(Kommune, ls, crop))*type_of_crop(crop,type)*Crop_cont(crop,comp)*ausbeute(crop));
    
*MR 20-04-24 animals cannot eat more than x% of their fibre demand
fodder_max_uptake(Kommune,ls,type)..
    FODDER_DEM(Kommune,ls,type,'fibre')*fodder_uptake_limit
    =g=
    sum((crop)$max_share(crop,ls),(BOUGHT_FEED(Kommune, ls, crop)+FODDER_PROD1(Kommune,ls,crop))*type_of_crop(crop,type)*Crop_cont(crop,'fibre'));

    
*feeding restrictions
feed_res(Kommune,type,ls,crop)$type_of_crop(crop,type)..
    (BOUGHT_FEED(Kommune, ls, crop)+FODDER_PROD1(Kommune,ls,crop))*type_of_crop(crop,type)
    =l=
    max_share(crop,ls)*sum(crop2$type_of_crop(crop2, type),FODDER_PROD1(Kommune,ls,crop2) + BOUGHT_FEED(Kommune, ls, crop2))
    ;

bought_feed_res(Kommune,ls,type)..
    max_bought_feed(type,ls)*sum(crop2$type_of_crop(crop2, type),FODDER_PROD1(Kommune,ls,crop2) + BOUGHT_FEED(Kommune, ls, crop2))
    =g=
    sum(crop$type_of_crop(crop,type),BOUGHT_FEED(Kommune,ls,crop));
    
*fix_bought_feed_res..
*    sum((Kommune, ls, crop), BOUGHT_FEED(Kommune, ls, crop))
*    =e=
*    fix_bought_feed;

    
    
***********************************
* BIOGAS PLANT MODULE *
***********************************
* SO 10.07.2025: Re-arrange to fit PALUD_BW version

* SO 10.07.2025: Rename biogas_dem1 and biogas_dem2 to biogas_supply1 and biogas_supply2
*                Right side of equation: BIOGAS_SUBSTRATE_SUPPLY (variable) instead of biogas_dem

* MR 14.02.2025 cover the demand for biogas substrate
*biogas_supply1(Kommune, substrate_fodder)..
*    sum(crop,FODDER_BIOGAS(Kommune, crop, substrate_fodder)*map_crop_subs(substrate_fodder, crop))
*    =e=
*    BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate_fodder);

* unit of biogas_dem is dt while MANURE_BIOGAS is t. Therefore divide biogas_dem by 10.
biogas_supply2(Kommune, substrate_manure)..
    sum((ls,type),MANURE_BIOGAS(Kommune, ls, type, substrate_manure)*map_ls_subs(substrate_manure, ls))*10
    =e=
    BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate_manure);
  
* SO 10.07.2025: Add this equation to match PALUD_BW
* MR 26-03-2025: problem: not enough animal manure to meet biogas demand (but CROP_SALE of fodder crops)
* idea: let model decide the share of excreta and plant material of the biogas input
biogas_dem_res(Kommune)..
    biogas_power_prod(Kommune)
    =e=
    sum(substrate, BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate) * power_from_substrate(substrate));

* MR 17.02.2025 the nutrients that went into the biogas plant
biogas_nutrients_eq(Kommune, Duenger, type)..
*    NUT_CONT_BIOGAS(Kommune, Duenger, type)
*    =e=
    sum((org_fert,ls, substrate_manure), MANURE_BIOGAS(Kommune, ls, type,substrate_manure) * map_ls_fert(ls, org_fert) * fert_nut_cont(org_fert, Duenger))
    + sum((crop,substrate_fodder),FODDER_BIOGAS(Kommune, crop, substrate_fodder)*Duenger_M(crop, Duenger)*type_of_crop(crop, type))
    =g=
    AMOUNT_BGL(Kommune,type)* fert_nut_cont('BGL',Duenger);


* SO 10.07.2025: Add this equation to match PALUD_BW
* MR 31.03.25 match the observed shares for each state. only use this equation when modelling full states, might become infeasible for single counties
*biogas_shares_res(state)..
*    (biogas_avg_excreta_share(state)/100) * sum((Kommune, substrate)$Location(Kommune, state),BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate))
*    =e=
*    sum((Kommune, substrate_manure)$Location(Kommune, state), BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate_manure));
*
*
* SO 10.07.2025: Instead of the equations below, Michaela uses the biogas_shares_res.
* MR 02.07.2025 this equation prohibits the input of organic plant material into the biogas plants to prevent having too much organic fertilizer
*biogas_no_org_plantmat..
*    sum((Kommune, oCrop, substrate_fodder), FODDER_BIOGAS(Kommune, oCrop, substrate_fodder))
*    =e=
*    0;
*
* MR 17.02.2025 amount of liquid biogas digestate in m³/t FM
* Assumption: 1 m³ of each substrate weights 1 ton and the digestate output is 90% of the input
* OLD:
*biogas_amount_eq(Kommune,type)..
*    AMOUNT_BGL(Kommune,type)
*    =e=
*    (sum((ls, substrate_manure),MANURE_BIOGAS(Kommune, ls, type, substrate_manure)) + sum((crop,substrate_fodder),FODDER_BIOGAS(Kommune, crop, substrate_fodder)/10))*0.9;
*
*biogas_amount_eq(Kommune,type)..
*    BGL_CONVERSION_FROM(Kommune, type)
*    =l=
*    AMOUNT_BGL(Kommune, type);

* SO 16.07.2025: Alternative simulation with biogas on LK level

biogas_supply1(substrate_fodder)..
    sum((Kommune, crop),FODDER_BIOGAS(Kommune, crop, substrate_fodder)*map_crop_subs(substrate_fodder, crop))
    =e=
    sum(Kommune, BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate_fodder));
*
** unit of biogas_dem is dt while MANURE_BIOGAS is t. Therefore divide biogas_dem by 10.
*biogas_supply2(substrate_manure)..
*    sum((Kommune, ls,type),MANURE_BIOGAS(Kommune, ls, type, substrate_manure)*map_ls_subs(substrate_manure, ls))*10
*    =e=
*    sum(Kommune, BIOGAS_SUBSTRATE_SUPPLIED(Kommune,substrate_manure));
*    

**************************************
*  CROP ROTATION CONSTRAINTS MODULE  *
**************************************

           
cultiv_area_eq(Kommune,type)..
    sum(Schlag_ID$(Location(Schlag_ID, Kommune)), sum(crop$(not Gcrop(crop)),CROPPROD(Schlag_ID,crop)*type_of_crop(crop,type)))
    =e=
    CULTIV_AREA(Kommune,type);

* SO 14-07-2025: Fruchtfolgebeschraenkung auf Landkreisebene, da sonst infeasible (insb. fuer oGetr)
cr_res(type,cgroup)..
    sum (Kommune, cgroup_max(cgroup)*CULTIV_AREA(Kommune,type))
    =g=
    sum((Kommune, crop)$(cropsin(cgroup,crop) and type_of_crop(crop, type)),
        CROP_KOMMUNE(Kommune,crop));

cr_res_lower..
    sum(Kommune, kg_lower_bound * CULTIV_AREA(Kommune,'org'))
    =l=
    sum(Kommune, CROP_KOMMUNE(Kommune, 'oKG')+CROP_KOMMUNE(Kommune, 'oKL')+CROP_KOMMUNE(Kommune, 'oSJ'));
    
*cr_res(Kommune,type,cgroup)..
*    cgroup_max(cgroup)*CULTIV_AREA(Kommune,type)
*    =g=
*    sum(crop$(cropsin(cgroup,crop) and type_of_crop(crop, type)),
*        CROP_KOMMUNE(Kommune,crop));
*
*cr_res_lower(Kommune)..
*    kg_lower_bound * CULTIV_AREA(Kommune,'org')
*    =l=
*    CROP_KOMMUNE(Kommune, 'oKG')+CROP_KOMMUNE(Kommune, 'oKL')+CROP_KOMMUNE(Kommune, 'oSJ');
*
	
********************************
*   LABOR CONSTRAINTS MODULE   *
********************************

lab_res(Kommune,timeframe)..
    lab_avail(Kommune, timeframe)
    =g=
    sum(crop, LABOR_CROP(Kommune, timeframe, crop))
    + sum((ls, type),LABOR_LS(Kommune, timeframe, ls, type));
    
labor_crop_eq(Kommune, timeframe, crop)..
    LABOR_CROP(Kommune, timeframe, crop)
    =e=
    sum(Schlag_ID$Location(Schlag_ID,Kommune),sum((soil, size)$Schlag_BG(Schlag_ID, soil, size),
        CROPPROD(Schlag_ID, crop) * lab_dem(crop, soil, size, timeframe)));
        
labor_ls_eq(Kommune, timeframe, ls, type)..
    LABOR_LS(Kommune, timeframe, ls, type)
    =e=
    lab_dem_ls(ls)*LS_PROD(Kommune,ls,type) / 24;

       
*************************
*  SIMULATE OF TARGET   *
*************************

* SO 07-11-2024: Equation added for simulating increase of organic shares by 2% per Year, 40% organic share until 2030   
*increase_org_shares(Kommune)$total_area(Kommune, 'all')..
*    sum((oCrop),CROP_KOMMUNE(Kommune, oCrop) / total_area(Kommune, 'all') * 100)
*    =g=
*    organic_share_boundary(Kommune, 'all')+2.8;

increase_org_shares$total_area_NUTS3('all')..
    sum((oCrop, Kommune)$(not Bcrop(ocrop)),CROP_KOMMUNE(Kommune, oCrop)) / total_area_NUTS3('all') * 100
    =g=
    organic_share_boundary2('all')+org_share_increase_lower;
    
increase_org_shares_upper$total_area_NUTS3('all')..
    sum((oCrop, Kommune)$(not Bcrop(ocrop)),CROP_KOMMUNE(Kommune, oCrop)) / total_area_NUTS3('all') * 100
    =l=
    organic_share_boundary2('all')+org_share_increase_upper+slack_OF;

**************************
*  SIMULATE SNH INCREASE *
**************************

* SO 26-06-2025: Equation added for simulating increase of SNH by XXX% per Year, 
increase_SNH_muni_lower(Kommune)..
     (CROP_KOMMUNE(Kommune, 'BL')+CROP_KOMMUNE(Kommune, 'oBL'))/total_area(Kommune, 'arable')*100
     =g=
     SNH_share_boundary_muni(Kommune)$total_area(Kommune, 'arable')+(snh_share_increase*(1-snh_offset_param));
     
*sum(Bcrop_arable, Landuse_SQ(Kommune, Bcrop_arable))+3;
increase_SNH..
*     sum(Bcrop_arable, CROP_KOMMUNE(Kommune, Bcrop_arable))/total_area(Kommune, 'arable')*100
     sum(Kommune, (CROP_KOMMUNE(Kommune, 'BL')+CROP_KOMMUNE(Kommune, 'oBL')))/sum(Kommune, total_area(Kommune, 'arable'))*100
     =g=
     SNH_share_boundary+snh_share_increase;

increase_SNH_upper..
*     sum(Bcrop_arable, CROP_KOMMUNE(Kommune, Bcrop_arable))/total_area(Kommune, 'arable')*100
     sum(Kommune, (CROP_KOMMUNE(Kommune, 'BL')+CROP_KOMMUNE(Kommune, 'oBL')))/sum(Kommune, total_area(Kommune, 'arable'))*100
     =l=
     SNH_share_boundary+snh_share_increase+slack_SNH;

***************************
* ADDITIONAL RESTRICTIONS *
***************************

* MR 24-01-2025 it is not allowed to change plots from organic to conventional
fix_org_plot_res(Schlag_ID)$(sum(oCrop,precrop(Schlag_ID,oCrop))>0)..
    sum(crop$(not oCrop(crop)), CROPPROD(Schlag_ID, crop))
    =e=
    0;

* MR 14-08-24 Silage and hay cannot be traded between municipalities (restriction not used)
*silage_trade_res_old..
*    sum((Kommune, ls),
*    BOUGHT_FEED(Kommune,ls,"GSM")
*    +BOUGHT_FEED(Kommune,ls,"oGSM")
*    +BOUGHT_FEED(Kommune,ls,"GHM")
*    +BOUGHT_FEED(Kommune,ls,"oGHM")
*    +BOUGHT_FEED(Kommune,ls,"SM")
*    +BOUGHT_FEED(Kommune,ls,"oSM")
*    +BOUGHT_FEED(Kommune,ls,"KG")
*    +BOUGHT_FEED(Kommune,ls,"oKG")
*    )
*    =l=
*    0;

* MR 16-12-24 silage and hay (Grundfutter) can be traded between municipalities in the same NUTS3 region
* Goal: Do not use =l= but =e=
silage_trade_res(NUTS3, fodder_crop)..
    sum(Kommune$Location_Kom(Kommune, NUTS3), sum(ls, BOUGHT_FEED(Kommune, ls, fodder_crop)))
    =e=
    sum(Kommune$Location_Kom(Kommune, NUTS3), CROP_SALE(Kommune, fodder_crop));
	

* SO 11-09-2025: Link herbivores to grassland
herbivores_res(Kommune, type)..
    sum(ls$ls_herb(ls), LS_PROD(Kommune, ls, type) * ls_unit(ls))
    =l=
    sum(gcrop$type_of_crop(gcrop,type), CROP_KOMMUNE(Kommune, gcrop))*lsu_herb_ha_grass_bound(Kommune, type)*1.1;
    

* MR 24-01-2 restrict the sale of fodder crops to the base level (not needed becaus we unse =e= in equation above)
*fodder_trade_res(Kommune, type)..
*    sum((fodder_crop)$type_of_crop(fodder_crop,type),
*        CROP_SALE(Kommune, fodder_crop))
*    =l=
*    fodder_sale_restriction(type) * lsu_herb(Kommune,type);
    
*fodder_trade_res_lower(Kommune, type)..
*    sum((fodder_crop)$type_of_crop(fodder_crop,type),
*        CROP_SALE(Kommune, fodder_crop))
*    =g=
*    0.8 * fodder_sale_restriction(type) * lsu_herb(Kommune,type);
    

  

Model minimal_constraints /          
Objf,
netret_muni,
netret_ls_eq
Area_res,
GL_Area_res,
AL_Area_res,
sum_crop,
cultiv_area_eq,               
yield_Kommune,
yield_distribution,
premium_of_eq,
premium_snh_eq,
no_org_fert
no_biogas_plant
/;


Model additional_calc /
        
* SO 16-01-2025 Calculate netreturn of organic farming and organic livestock farming
netret_org_eq
netret_ls_org_eq
* SO 16-091-2025: Calculate netreturn of crops (production costs - sale)
netret_crops_eq                
* SO 17-01-2025: Calculate cereal units
CU_eq
/;

Model organic_fertilizer_coverage /
manure_res_lower              
org_fert_eq
nut_manure_eq
nut_biogas_eq
nut_ext_eq  
nut_intercrop_eq
nut_gmm_eq
manure_avail_eq
biogas_conversion_res
conversion_res1
conversion_res2
*bought_fertilizer_res
gm_intercrop_res
gm_maincrop_res
manure_res_upper
n_res
org_fert_cost_eq
duenger_trade_res                      
/;

Model livestock_feed_demand /              
fodder_max_uptake,
fodder_dem_res,
feed_res,
bought_feed_res                            
fodder_dem_eq 
/;

Model biogas_plant /            
* MR 14.02.25 biogas plants and nutrient budgets                                                                                                                     
biogas_supply1
biogas_supply2
biogas_dem_res              
biogas_nutrients_eq
* MR: only use the next equation if running a whole state         
*biogas_shares_res
/;

Model crop_rotation_constraints /
cr_res
cr_res_lower
/;

Model labor_constraints /
lab_res
labor_crop_eq
labor_ls_eq
/;
                                                 
Model core /
minimal_constraints
additional_calc
set_aside
organic_fertilizer_coverage-no_org_fert
livestock_feed_demand
biogas_plant-no_biogas_plant
crop_rotation_constraints
labor_constraints
herbivores_res
/;




Model Base /
core
-yield_Kommune
-crop_rotation_constraints
*- AL_area_res
baseline
Fix_Livestock_to_SQ
yield_Kommune_base
/;

**** Models for sensitivity analyses
*Solve Base using LP maximizing NETRETURN;
*
*parameter res_crop_group_share1(Kommune, cgroup,type);
*res_crop_group_share1(Kommune, cgroup,type)$CULTIV_AREA.L(Kommune,type) = sum(crop$(cropsin(cgroup,crop) and type_of_crop(crop, type)), CROP_KOMMUNE.L(Kommune,crop)) / CULTIV_AREA.L(Kommune,type) * 100;
*$stop

Model prevent_extrem_changes /
SQ_Kommune_GL,
SQ_Kommune_upper,
SQ_Kommune_lower,
SQ_Kommune_ini,
SQ_Kommune_ini2,
SQ_crop_upper,
SQ_crop_lower,
SQ_bcrop_upper,                
** MR 19.11.2024 - make livestock numbers a variable                  
SQ_Livestock_res_upper        
SQ_Livestock_res_lower
*                    
** SO 20-01-2025: Restrict livestock
SQ_Livestock_upper
SQ_Livestock_lower
SQ_Livestock_ini
/;

Model Farm /
core
*Fix_Livestock_to_SQ
fix_org_plot_res
SQ_Kommune_GL,

*** SO 20-01-2025: Restrict livestock
SQ_Livestock_upper
SQ_Livestock_lower
*SQ_bcrop_upper
SQ_crop_upper
SQ_crop_lower
SQ_Kommune_ini,
SQ_Kommune_ini2,

increase_snh_muni_lower
increase_snh
increase_snh_upper
increase_org_shares
increase_org_shares_upper
/;


Farm.optfile=1;

OPTION LP=CPLEX;
OPTION optcr=0.05;
OPTION ITERLIM = 100000000;
OPTION RESLIM = 100000000;
OPTION Threads=8;
option Solprint = off;
OPTION Limcol=0;
OPTION LimRow=0;


$onecho > cplex.opt
names 0
nodefileind 3

$offecho
;

Model FarmOF /
core
fix_org_plot_res
SQ_Kommune_GL,

*** SO 20-01-2025: Restrict livestock
SQ_Livestock_upper
SQ_Livestock_lower
*SQ_bcrop_upper
SQ_crop_upper
SQ_crop_lower
SQ_Kommune_ini,
SQ_Kommune_ini2,

increase_snh_muni_lower
increase_snh
increase_snh_upper
increase_org_shares
increase_org_shares_upper
/;

FarmOF.optfile=1;

OPTION LP=CPLEX;
OPTION optcr=0.05;
OPTION ITERLIM = 100000000;
OPTION RESLIM = 100000000;
OPTION Threads=4;
option Solprint = off;
OPTION Limcol=0;
OPTION LimRow=0;

Model test_OF /
core
fix_org_plot_res
*prevent_extrem_changes
SQ_Kommune_GL,
SQ_Kommune_upper
SQ_Kommune_lower
SQ_Livestock_upper
SQ_Livestock_lower
*-SQ_Livestock_ini
SQ_bcrop_upper
SQ_crop_upper
SQ_crop_lower

increase_snh_muni_lower
increase_snh
increase_snh_upper
increase_org_shares
increase_org_shares_upper
/;


Model FarmSNH /
core
fix_org_plot_res
SQ_Kommune_GL,

*** SO 20-01-2025: Restrict livestock
SQ_Livestock_upper
SQ_Livestock_lower
*SQ_bcrop_upper
SQ_crop_upper
SQ_crop_lower
SQ_Kommune_ini,
SQ_Kommune_ini2,

increase_snh_muni_lower
increase_snh
increase_snh_upper
increase_org_shares
increase_org_shares_upper
/;

Model FarmMIX /
core
fix_org_plot_res
SQ_Kommune_GL,

*** SO 20-01-2025: Restrict livestock
SQ_Livestock_upper
SQ_Livestock_lower
*SQ_bcrop_upper
SQ_crop_upper
SQ_crop_lower
SQ_Kommune_ini,
SQ_Kommune_ini2,

increase_snh_muni_lower
increase_snh
increase_snh_upper
increase_org_shares
increase_org_shares_upper
/;

Model FarmMAX /
core
fix_org_plot_res
SQ_Kommune_GL,

*** SO 20-01-2025: Restrict livestock
SQ_Livestock_upper
SQ_Livestock_lower
*SQ_bcrop_upper
SQ_crop_upper
SQ_crop_lower
SQ_Kommune_ini,
SQ_Kommune_ini2,

increase_snh_muni_lower
increase_snh
increase_snh_upper
increase_org_shares
increase_org_shares_upper
/;

$include utility_functions\set_result_parameters.gms

temp_no_animals(Kommune, ls, type) = 0;
