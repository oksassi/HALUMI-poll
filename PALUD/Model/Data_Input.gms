****************************************************
*  Model Data Input Baden-Wuerttemberg             *
****************************************************
* s= ./t/BW

*set municipalities
$INCLUDE filepath.inc

$if not set muni $set muni 08126011

sets
year                all years that potentially will be modelled
/base, 2016*2050/

ref_year_ls(year)
/2016, 2020/

ref_year_crop(year)
/2016*2022/

Schlag_ID           plot IDs for all plots arable crop land and permanent grass land 
/
$include %filepath%Input\New_Land_ID_Hohenlohe.csv
/

GL_ID(Schlag_ID)    plot IDs for permanent grassland
/
$include %filepath%Input\New_GLand_ID_Hohenlohe.csv
/

Kommune /
*%muni%
$include %filepath%Input\municipalities.txt

*, 08415028, 08415039, 08415078,
*08415073, 08415088, 08415089, 08415090

* SO 10-07-2025: Hohenlohe

*%municipalities%
*all municipalitites exept those who don't fullfill cr_res and cr_res_lower
*08415014,08415019,08415027,08415028,08415034,08415039,08415048,08415053,08415058,08415059,
*08415061,08415073,08415078,08415080,08415085,08415088,08415089,08415090,08415091,08415092,08415971
/

state /
DE1, DE2, DE3, DE4, DE5, DE6, DE7, DE8, DE9, DEA, DEB, DEC, DED, DEE, DEF, DEG
/,

Soil /gering, mittel, hoch/,
size /1, 2, 5, 10/,
Crop        all crop types and grassland farming types
/SO, Erd, GE, Ha, Ka, KG, KL, KM, Rog, SB, SG, SJ, SM, Som, WG, Win,
 WR, WW, ZR, B, BG, BL,
 oSO, oErd, oGE, oHa, oKa, oKG, oKL, oKM, oRog, oSB, oSG, oSJ, oSM, oSom, oWG, oWin,
 oWR, oWW, oZR, oB, oBG, oBL,
 GSM, GHM, oGSM, oGHM/
Acrop(Crop) arable crops
/SO, Erd, GE, Ha, Ka, KG, KL, KM, Rog, SB, SG, SJ, SM, Som, WG, Win,
 WR, WW, ZR, B, BL,
 oSO, oErd, oGE, oHa, oKa, oKG, oKL, oKM, oRog, oSB, oSG, oSJ, oSM, oSom, oWG, oWin,
 oWR, oWW, oZR, oB, oBL/
Gcrop(Crop) types of permanent grassland farming
/GSM, GHM, BG, oGSM, oGHM, oBG/ 

* ARABLE CROPS:
* SO:   sonstiges
* Erd:  Erdbeeren (no labor demand available for Erd)
* GE:   Gemüse  
* Ha:   Hafer
* Ka:   Kartoffeln
* KG:   Kleegras
* KL:   Körnerleguminosen
* KM:   Körnermais
* Rog:  Winterroggen
* SG:   Sommergerste
* SJ:   Sojabohnen
* SM:   Silomais
* Som:  Sonsiges Sommergetreide (Sommerroggen)
* WG:   Wintergerste
* Win:  sonstiges Wintergetreide (Triticale)
* WR:   Winterraps
* WW:   Winterweizen
* ZR:   Zuckerrübe
* B:    Brache auf Ackerland
* BG:   Brache auf Grünland
* BL:   Blühfläche
* SB:   Sonnenblumen und weitere Ölfrüchte

* TYPES OF GRASSLAND FARMING:
* GSM: silage, medium intensive
* GHM: hay, medium intensive
* more to come

*organic crops
oCrop(Crop) /oSO, oErd, oGE, oHa, oKa, oKG, oKL, oKM, oRog, oSB, oSG, oSJ, oSM, oSom, oWG, oWin,
 oWR, oWW, oZR, oGSM, oGHM, oB, oBG, oBL/
 
fodder_crop(Crop)
/GSM, oGSM, GHM, oGHM, KG, oKG, SM, oSM/

vegetable(oCrop)
/
oGE, oKa, oErd
/

springcrop(crop)
/ ZR, oZR, Ha, oHa, Ka, oKa, KL, oKL, KM, oKM, SB, oSB, SG, oSG, SM, oSM, Som, oSom, SO, oSO, Erd, oErd, GE, oGE
/

*crops that can be used as green manure
gmcrop(crop)
/KG, oKG/
 
*konventional arable crops
kCrop(crop) /Ha, Ka, KG, KL, KM, Rog, SB, SG, SM, SJ, Som, WG, Win, WR, WW, ZR, SO, Erd, GE, B, BG, BL, GSM, GHM/
Bcrop(crop) /B, oB, BG, oBG, BL, oBL/
Bcrop_arable(crop) /B, oB, BL, oBL/
Bcrop_grassland(crop) /BG, oBG/
SNH(crop) /BL, oBL/

map_konv_org(kCrop, oCrop)
/
Ha.oHa
Ka.oKa
KG.oKG
KL.oKL
KM.oKM
Rog.oRog
SB.oSB
SG.oSG
SM.oSM
Som.oSom
WG.oWG
Win.oWin
WR.oWR
WW.oWW
ZR.oZR
SO.oSO
Erd.oErd
GE.oGE
SJ.oSJ
GHM.oGHM
GSM.oGSM
BL.oBL
B.oB
BG.oBG
/

*MR 28-03-24 livestock
ls /R, M, S, Sch, Eh, Z, H/
* R: Rinder ohne Milchkühe
* M: Milchkühe
* S: Schweine
* Sch: Schafe
* Eh: Einhufer
* Z: Ziegen
* H: Hühner

* SO 11-09-2025 herbivores
herbivores(ls) /R, M, Sch, Eh, Z/



* MR 14-02-2025 improve nutrient budgets
* incorporation of organic fertilizers in addition to livestock manure
org_fert /
R
M
S
Sch
Eh
Z
H
CPC     compost from landfill - park cuttings
CHH     compost from landfill - household waste
PFW     potato fruit water concentrate
HML     hair meal
KAL     potassium mineral fertilizer
BGL     biogas digestate liquid
GMN     green manure
CHA     champost
/

ext_org_fert(org_fert) /
CPC, CHH, PFW, HML, KAL, CHA
/

* MR 14-02-2025 biogas substrate
substrate /
RM      dairy and cattle manure
S       pig manure
SchEhZ  sheet goat and horse manure
H       chicken manure
LS      any livestock manure
SM      silage maize
Gras    gras silgae: KG or GSM
Plant   any plant material
/

substrate_fodder(substrate)
/ SM, Gras, Plant/

substrate_manure(substrate)
/ RM, S, SchEhZ, H, LS/

NUTS2 /1,2,3,4/
NUTS3 /
$include %filepath%Input\LK_ID.csv
/

Duenger /N, P, K/

type /org, conv/
comp /energy, protein, fibre/

*MR 02-08-24 labor demand
timeframe /
ANY, JAN1, JAN2, FEB1, FEB2, MRZ1, MRZ2, APR1, APR2, MAI1, MAI2, JUN1, JUN2,
JUL1, JUL2, AUG1, AUG2, SEP1, SEP2, OKT1, OKT2, NOV1, NOV2, DEZ1, DEZ2
/

*MR 05-08-24 to make model without CropRota
cgroup /
RaRue
Ka
KL
oRaRue
oKa
oKL
oGetr
oWW
oWinter
oSommer
/

* SO 12-11-2024: Map GSM, GHM & oGSM, oGHM.
GHMcrop(crop) /oGHM, GHM/
GSMcrop(crop) /oGSM, GSM/
BGcrop(crop) /oBG, BG/
BLcrop(crop) /oBL, BL/
map_GHM_GSM(GHMcrop, GSMcrop)/
GHM.GSM
oGHM.oGSM/

map_crop_subs(substrate_fodder,crop)
/
SM.SM
SM.oSM
Gras.GSM
Gras.oGSM
Gras.KG
Gras.oKG
/

map_ls_subs(substrate_manure, ls)
/
RM.R
RM.M
S.S
SchEhZ.Sch
SchEhZ.Eh
SchEhZ.Z
H.H
/

map_ls_fert(ls, org_fert)
/
R.R
M.M
S.S
Sch.Sch
Eh.Eh
Z.Z
H.H
/
;
map_crop_subs('Plant',crop) = 1;
map_ls_subs('LS', ls) = 1;

Alias(crop, crop2)
Alias(type, type1)


* SO 16.07.2025: Add set
set map_konv_org_all(crop, crop2)
/
Ha.oHa
Ka.oKa
KG.oKG
KL.oKL
KM.oKM
Rog.oRog
SB.oSB
SG.oSG
SM.oSM
Som.oSom
WG.oWG
Win.oWin
WR.oWR
WW.oWW
ZR.oZR
SO.oSO
Erd.oErd
GE.oGE
oHa.Ha
oKa.Ka
oKG.KG
oKL.KL
oKM.KM
oRog.Rog
oSB.SB
oSG.SG
oSM.SM
oSom.Som
oWG.WG
oWin.Win
oWR.WR
oWW.WW
oZR.ZR
oSO.SO
oErd.Erd
oGE.GE
/
sets
type_unequal(type, type1)
/
org.conv
conv.org
/
;

Parameter
Schlag_ha(Schlag_ID)                    Size of the plot in ha
Schlag_BG(Schlag_ID, soil, size)        Soil quality and size of the plot
Location(Schlag_ID, Kommune)            Location of the plot municipality
Location_Kom(Kommune, NUTS3)            In which NUTS3 region (Landkreis) lies the municipality
RP(Schlag_ID, NUTS2)                    Location in the NUTS2 region
LK(Schlag_ID, NUTS3)                    Location in the NUTS3 region
Yield(Crop, Soil, size)                 Crop Yield by soil quality
Price(crop)                             Producer prices by crop
Pest_cost(crop, soil, size)             Pesticide costs by crop and soil quality
Seeds(crop, soil, size)                 Seeds costs by crop and soil quality
Repair(crop, soil, size)                repairing costs by crop soil and size
Diesel(crop, soil, size)                Diesel demand by crop soil and size
Ex_machinery(crop, soil, size)          External machinery costs by crop soil and size
wages(crop, soil, size)                 variable labour costs by crop soil and size
drying(crop, soil, size)                costs for drying by crop soil and size
other_costs(crop, soil, size)           other costs by crop soil and size
* SO 20-06-2023: added working hours which can be added as a constraint e.g. using thresholds from FADN data on NUTS2 level
working_hours(crop, soil, size)         time needed for conducting fieldwork in h_ha

Landuse(Schlag_ID,Crop,year)            Landuse in each year
Landuse_SQ(Kommune, Crop)               Status quo land use by municipality (seperate for organic and conventional)
Landuse_SQ_crop(Kommune, Crop)          Status quo landuse by municipality (organic and conventional added together)
Landuse_SQ_base(Kommune, crop)          Status quo landuse by municipality (separate for organic and conventional) in base year
* SO 03-12-2024 
Landuse_SQ_GL(Kommune, GHMcrop)         Status quo hay production (area) by municipality (organic and conventional added together)

Duenger_M(Crop, Duenger)                Crop demand for fertilizer per dt of yield
* Bei KL & SJ negativer N demand wegen Gründüngungseffekt
Duenger_P(Duenger)                      Fertilizer prices
Fertilizer(crop, soil, size)            fertilizer costs by crop soil and size
* errechnet sich aus Duenger_M und Duenger_P

* MR 28-03-24 incorporating organic farming
Premium_OF(Crop)                        premium for continous organic farming in BaWue according to FAKT II
Premium_SNH(Crop)                       premium for SNH
type_of_crop(crop, type)                classiefies each crop either as conventional or organic

*MR 02-04-24 adding livestock to PALUD
Livestock_SQ(Kommune, ls, type)         Status quo amount of org. and conv. livestock kept on municipal level (number of animals)
Livestock_SQ_base(Kommune, ls, type)    Status quo amount of org. and conv. livestock kept on municipal level (number of animals)_ base
Livestock_total(ls, type)               Status quo amount of org. and conv. livestock kept on NUTS3 level (number of animals)

Ls_dem(ls,comp)                         Energy protein and fibre demand of livestock in MJ ME and g per day
Ls_gm(ls,type)                          gross margin per animal
Lab_dem_ls(ls)                          Labor demand in hours per animal per year
* SO 25-01-2025: To analyze the difference between conventional and organic labor demand for crops
Lab_dem_crop(crop)                      Labor demand in hours per crop (average over soil_ size and month)
manure_prod(ls)                         m³ or tons of manure produced per animal
fert_nut_cont(org_fert, Duenger)        kg N P K per m³ or ton of organic fertilizer
fert_price(org_fert)                    price for organic fertilizer per m³ or ton
fert_n_eff(org_fert)                    N use efficiency of organic fertilizer
fert_eff(org_fert, Duenger)             efficiency of organic fertilizer
ls_unit(ls)                             how many livestock units is one animal

*MR 12-04-24 Fodder for livestock
max_share(crop,ls)                      defines the maximal shares for each crop in a feed ration
max_bought_feed(type,ls)                defines the maximum share of bought animal feed
Dgr_yield(Kommune)                      yield in dt dry matter per ha on a five year average per Landkreis
dry_matter_content(crop)                dry matter content necessary for yields in permanent grassland
Crop_cont(crop,comp)                    nutrient components of crop needed by livestock
ausbeute(crop)                          Share of soybean and rapeseed meal gained from the beans and grains

*MR 02-08-24 labour constraints
lab_dem(crop, soil, size, timeframe)    Working hrs needed per ha for each crop in a certain timeframe

*MR 06-08-24 to model without CropRota: Groups for Crop Rotation Constraints
cropsin(cgroup,crop)                    crops that belong to each crop group
cgroup_max(cgroup)                      maximal share of each crop group
precrop(Schlag_ID,crop)                 crop grown in the year before
precrop_base(Schlag_ID,crop)                 crop grown in base
combival_P(crop, crop2)                 expert-based score matrix with pre-crops and main crops taken from CropRota

price_manure_buy(NUTS3, type, Duenger)
price_manure_sale(NUTS3, type, Duenger)

*MR 03-12-24 calibration (backcasting): reference values
ref_crop(year, Kommune, crop)  reference: true values for cultivated area of crop in year and kommune in ha
ref_ls(year, Kommune, ls)        reference: true values for number of animals (org plus conv) in year and kommune

* SO 17-01-2025 cereal units
GE(Crop)                                Cereal units by crop unit

* MR 14.02.2025 biogas plant
*biogas_power_rating(Kommune)            total biogas power rating in kW per Kommune (actual data is per county)
biogas_installed_capa(Kommune)          total installed power capacity in kW
*biogas_demand(substrate)                demand of each substrate in t FM per kW power rating
*biogas_dem(Kommune,substrate)           total demand of each substrate in dt FM per Kommune
biogas_power_prod(Kommune)              electricity produced per Kommune
*biogas_dem_excreta(Kommune)             amount of manure substrate needed for biogas in t FM
*biogas_dem_plantmat(Kommune)            amount of plant material substrate (fodder) needed for biogas in t FM
*share_excreta(Kommune)                  state specific share of excreta on biogas substrate
*share_plantmat(Kommune)                 state specific share of plant material on biogas substrate
*substrate_share(substrate)              least share of specific substrate divided by plant material and manure
* SO 09-07-2025
biogas_avg_excreta_share(state)         state specific share of excreta of biogas substrate
power_from_substrate(substrate)         electricity in kWh from 1 deciton of manure or silage (calculated from LfL)
;

Scalar
transport_fee                           cost for transport of bought animal feed in % (1.1 means 10 % transport cost)
/1.2/
Diesel_P                                Diesel price in EUR per liter
/1.05/

*MR 24-02-25 biogas
biogas_util                             share of installed biogas capacity that is actually used
* SO 10-11-2025: Actually 6652 kW which is 55%.
* But it is realistic that not all areas that are used for biogas production (e.g., maize monocultures) are found in the IACS data (e.g., maize monocultures)
/0.5/
power_from_excreta                      electricity in kWh from 1 ton of manure (calculated from LfL)
/75/
power_from_plantmat                     electricity in kWh from 1 ton of plant silage (calculated from LfL)
/350/
;



*electricity in kWh from 1 deciton of manure/silage (calculated from LfL)
power_from_substrate(substrate_fodder) = 35;
power_from_substrate(substrate_manure) = 7.5;



cropsin('RaRue','ZR') = 1;
cropsin('RaRue','WR') = 1;
cropsin('oRaRue','oZR') = 1;
cropsin('oRaRue','oWR') = 1;
cropsin('Ka','Ka') = 1;
cropsin('oKa','oKa') = 1;
cropsin('KL','KL') = 1;
cropsin('KL','SJ') = 1;
cropsin('oKL','oKL') = 1;
cropsin('oKL','oSJ') = 1;
cropsin('oGetr','oWW') = 1;
cropsin('oGetr','oWG') = 1;
cropsin('oGetr','oWin') = 1;
cropsin('oGetr','oSom') = 1;
cropsin('oGetr','oRog') = 1;
cropsin('oGetr','oHa') = 1;
cropsin('oGetr','oSG') = 1;
cropsin('oWinter','oWW') = 1;
cropsin('oWinter','oWG') = 1;
cropsin('oWinter','oWin') = 1;
cropsin('oWinter','oWR') = 1;
cropsin('oWinter','oRog') = 1;
cropsin('oSommer','oZR') = 1;
cropsin('oSommer','oHa') = 1;
cropsin('oSommer','oKa') = 1;
cropsin('oSommer','oKL') = 1;
cropsin('oSommer','oKM') = 1;
cropsin('oSommer','oSB') = 1;
cropsin('oSommer','oSG') = 1;
cropsin('oSommer','oSM') = 1;
cropsin('oSommer','oSom') = 1;
cropsin('oSommer','oSO') = 1;
cropsin('oSommer','oErd') = 1;
cropsin('oSommer','oGE') = 1;
cropsin('oWW','oWW') = 1;

cgroup_max('RaRue') = 0.34;
cgroup_max('Ka') = 0.26;
cgroup_max('KL') = 0.26;
cgroup_max('oRaRue') = 0.34;
cgroup_max('oKa') = 0.26;
cgroup_max('oKL') = 0.26;
cgroup_max('oGetr') = 0.67;
cgroup_max('oWW') = 0.34;
cgroup_max('oWinter') = 0.6;
cgroup_max('oSommer') = 0.6;


* SO 17-01-2025: 

* Gross margins for livestock per animal
Ls_gm('R',type) = 475;
Ls_gm('M',type) = 1619;
Ls_gm('S',type) = 150;
Ls_gm('Sch',type) = 72;
Ls_gm('Z',type) = 126;
Ls_gm('Eh',type) = 2099;
Ls_gm('H',type) = 8.36;

type_of_crop(crop, 'conv') = 1;
type_of_crop(oCrop, 'conv') = 0;
type_of_crop(oCrop, 'org') = 1;

dry_matter_content('GSM') = 0.35;
dry_matter_content('oGSM') = 0.35;
dry_matter_content('GHM') = 0.86;
dry_matter_content('oGHM') = 0.86;
dry_matter_content('BG') = 0.35;
dry_matter_content('oBG') = 0.35;


*MR 10-07-24 Duenger price set equal for all crops
Duenger_P('N') = 0.9;
Duenger_P('P') = 0.75;
Duenger_P('K') = 0.7;

max_bought_feed('conv',ls) = 1.0;
max_bought_feed('org',ls) = 0.3;
max_bought_feed('org','S') = 0.7;
max_bought_feed('org','H') = 0.7;

*MR 24-04-24 if rapeseed or soybean meal is fed, the availabe rapeseed or soybean meal is not 100% of the yield as the oil gets taken away
*A gain from selling the oil when feeding own rapeseed or soybean is currently not considered as it might not be practial for the majority of farmers to do so (?)
ausbeute(crop) = 1;
ausbeute('WR') = 0.7;
ausbeute('oWR') = 0.7;
ausbeute('SJ') = 0.8;
ausbeute('oSJ') = 0.8;

* MR 14-0-2025 biogas power rating for Münsingen
* According to EE-Monitor (2024). Monitoring for a nature-friendly energy transition in Germany. https://ee-monitor.de/.
* https://web.app.ufz.de/ee-monitor/re-plant-locations/webgis
* Münsingen has 6.1 % of the biogas power rating of Reutlingen county
* but: discrepancy: EE-Monitor says 29 400 KW for Reutlingen while LEL says 13 684 KW for Reutlingen county
* biogas_power_rating('08415053') = 13684 * 0.061;
* not enought manure! reduce power rating
* biogas_power_rating('08415053') = 720;

* the following 3 lines are now in an external xlsx file
*biogas_installed_capa('08415053') = 1794;
*share_excreta('08415053') = 0.375;
*share_plantmat('08415053') = 0.62;
*substrate_share('RM') = 0.80;
*substrate_share('S') = 0.105;
*substrate_share('SchEhZ') = 0.005;
*substrate_share('LS') = 0.09;
*substrate_share('SM') = 0.5;
*substrate_share('Gras') = 0.05;
*substrate_share('Plant') = 0.45;
*
$onecho > tasks.txt

par=Yield       rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,6:14
par=Pest_cost   rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5,7:14
par=Seeds       rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5:6,8:14
par=Repair      rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5:7,9:14
par=Diesel      rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5:8,10:14
par=wages       rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5:9,11:14
par=drying      rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5:11,13:14
par=other_costs rng=prod_data!a1                   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=2,5:12,14
par=Duenger_M   rng=fertilizer_demand!a1           rdim=1 cdim=1
par=Price     rng=crop_prices!a1                   rdim=1 cdim=0   ignoreRows=1
$offecho

$call GDXXRW "%filepath%Input/Kalk_Daten_BW_2.xlsx"   trace=3 @tasks.txt  maxDupeErrors = 100000



*** GDX File aus Excel-Datei erzeugen

$onecho > tasks.txt

par=Schlag_ha       rng=Sheet1!a1   rdim=1 cdim=0   ignoreRows=1  ignoreColumns=2:7,9:11
par=Schlag_BG       rng=Sheet1!a1   rdim=3 cdim=0   ignoreRows=1  ignoreColumns=2:5,8:11
par=Location        rng=Sheet1!a1   rdim=2 cdim=0   ignoreRows=1  ignoreColumns=3:11
par=Location_Kom    rng=Loc_Kom!a1  rdim=2 cdim=0   ignorerows=1  
par=RP              rng=Sheet1!a1   rdim=2 cdim=0   ignoreRows=1  ignoreColumns=2:9,11
par=LK              rng=Sheet1!a1   rdim=2 cdim=0   ignoreRows=1  ignoreColumns=2,3,5:11
par=precrop_base    rng=Sheet1!a1   rdim=2 cdim=0   ignoreRows=1  ignoreColumns=2:10
$offecho

$call GDXXRW %filepath%Input/Plots_DE119_2021.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

$onecho > tasks.txt
* SO 17-01-2025: Cereal units per crop
par=GE rng=Sheet1!a1   rdim=1 cdim=0   ignoreRows=1

$offecho

$call GDXXRW %filepath%Input/GE_unit_BW.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** Reading in livestock data
$onecho > tasks.txt

par=Livestock_SQ_base   rng=ls_sq2020!a1        rdim=3 cdim=0 ignoreRows=1
par=Ls_dem              rng=ls_dem!a1           rdim=1 cdim=1 ignoreRows=1
par=manure_prod         rng=manure_prod!a1      rdim=1 cdim=0 ignoreRows=1
par=fert_nut_cont       rng=fert_nut_cont!a1    rdim=1 cdim=1 ignoreRows=1      ignoreColumns=2:3,5,8:13
par=fert_price          rng=fert_nut_cont!a1    rdim=1 cdim=0 ignoreRows=1,2    ignoreColumns=2:12
par=fert_n_eff          rng=fert_nut_cont!a1    rdim=1 cdim=0 ignoreRows=1,2    ignoreColumns=2:10,12:13
par=Crop_cont           rng=crops_nut_cont!a1   rdim=1 cdim=1 ignoreRows=1      ignoreColumns=2,6:10
par=max_share           rng=max_share!a1        rdim=2 cdim=0 ignoreRows=1
par=Lab_dem_ls          rng=lab_dem_ls!a1       rdim=1 cdim=0 ignoreRows=1,2    ignoreColumns=3,4
par=price_manure_buy    rng=manure_price!a1     rdim=2 cdim=1 ignoreRows=1      ignoreColumns=6:8
par=price_manure_sale   rng=manure_price!a1     rdim=2 cdim=1 ignoreRows=1      ignoreColumns=3:5
par=ls_unit             rng=GV!a1               rdim=1 cdim=0 ignoreRows=1


$offecho
$call GDXXRW %filepath%Input/Livestock_data_Hohenlohe0.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** Reading in Gruenland_Ertrag
$onecho > tasks.txt

par=Dgr_yield rng=Tabelle1!a1   rdim=1 cdim=0   ignoreRows=1

$offecho
$call GDXXRW %filepath%Input/Gruenland_Ertrag.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** Reading in labor demand
$onecho > tasks.txt

par=lab_dem rng=Sheet1!a1   rdim=4 cdim=0   ignoreRows=1    ignoreColumns=2

$offecho
$call GDXXRW %filepath%Input/KTBL_labor_demand.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** Einlesen der CR-Matrix
$onecho > tasks.txt

par=combival_P rng=Sheet1!a1   rdim=1 cdim=1   ignoreRows=0   ignoreColumns= 0

$offecho

$call GDXXRW %filepath%Input/Croprotation_matrix_BW_comb_4.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** SO 08-07-2025: Einlesen der installierten Anlagenkapazität Biogas pro Region
$onecho > tasks.txt

par=biogas_installed_capa   rng=Sheet1!a1    rdim=1 cdim=0   ignoreRows=1   ignoreColumns=2
par=biogas_avg_excreta_share rng=biogas_share!a1 rdim=1 cdim=0 ignoreRows=1

$offecho

$call GDXXRW %filepath%Input/biogas_DE119_2021.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** Reading in reference values
$onecho > tasks.txt

par=ref_crop rng=crop!a1        rdim=3 cdim=0   ignoreRows=1    ignoreColumns=0
par=ref_ls   rng=livestock!a1   rdim=3 cdim=0   ignoreRows=1    ignoreColumns=0

$offecho
$call GDXXRW %filepath%Input/Reutlingen_calib_2016_2022.xlsx   trace=3 @tasks.txt  maxDupeErrors = 100000

*** GDX File einlesen

$GDXIN  %filepath%Model\Plots_DE119_2021.gdx
$LOAD   Schlag_ha Schlag_BG  Location Location_Kom RP LK precrop_base
$GDXIN

$GDXIN  %filepath%Model\Kalk_Daten_BW_2.gdx
$LOAD   Yield Pest_cost Seeds Repair Diesel wages drying other_costs Duenger_M Price
$GDXIN

$GDXIN  GE_unit_BW.gdx
$LOAD   GE
$GDXIN

$GDXIN  %filepath%Model\Livestock_data_Hohenlohe0.gdx
$LOAD   Livestock_SQ_base Ls_dem manure_prod fert_nut_cont fert_price fert_n_eff Crop_cont max_share Lab_dem_ls price_manure_buy price_manure_sale ls_unit
$GDXIN

$GDXIN  %filepath%Model\Gruenland_Ertrag.gdx
$LOAD   Dgr_yield
$GDXIN

$GDXIN  %filepath%Model\KTBL_labor_demand.gdx
$LOAD   lab_dem
$GDXIN

$GDXIN  %filepath%Model\Croprotation_matrix_BW_comb_4.gdx
$LOAD   combival_P
$GDXIN

$GDXIN  %filepath%Model\biogas_DE119_2021.gdx
$LOAD   biogas_installed_capa biogas_avg_excreta_share
$GDXIN

$GDXIN  %filepath%Model\Reutlingen_calib_2016_2022.gdx
$LOAD   ref_crop ref_ls
$GDXIN

*** Calculation the costs for fertilization 
Fertilizer(crop, soil, size)$(not ocrop(crop)) = (sum(Duenger,
                                            (Yield(crop, soil, size)*
                                            (Duenger_M(Crop, Duenger))*
                                            Duenger_P(Duenger))))

Set
p /all,arable,grassland/
ls_herb(ls) /R,M,Sch,Z,Eh/;

Parameter
ha_Kommune(Kommune)                     Total agricultural and area in ha per municipality
lab_avail(Kommune,timeframe)            available labor per Kommune
size_share(Kommune,size)                share of each field size per Kommune
soil_share(Kommune,soil)                share of each soil type per Kommune
soil_size_share(Kommune, soil, size)    share of each soil type and size combination per municipality
avg_lab_avail(Kommune)                  average available labor hours per timeframe
vorfruchtwert_SQ(Kommune,type)          average "pre crop value" per ha of status que land use
total_area_SQ                           total agricultureal area per municipality from Landuse_SQ
org_share_SQ                            Status Quo: percentage of organic agriculture per Kommune
snh_share_SQ                            Status Quo: percentage of SNH or fallow land per Kommune
org_share_LK_SQ
snh_share_LK_SQ
* SO 11-09-2025
lsu_herb_ha_grass_SQ(Kommune, type)     Share of herbivore lsu on grassland municipality
lsu_herb_ha_grass_SQ_NUTS3(type)        Share of herbivore lsu on grassland NUTS3
lsu_herb_ha_grass_bound(Kommune, type)  Upper bound for stocking density of herbivores per farming type and municipality
livestock                               number of livestock per municipality
ls_share_org                            percentage of organic livestock per livestock category
ls_share_org_herb                       percentage of organic livestock over all herbivore livestock categories
lsu                                     livestock units per Kommune and animal category
lsu_herb                                livestock units of herbivorous animals per Kommune
fodder_area_sq                          SQ area in ha on which fodder crops are grown per Kommune
lsu_herb_ha                             LSU per ha (only herbivorous animals) per Kommune
* SO 17-01-2025: calculation of the number of cereal units per crop rotation and field
cereal_unit(Schlag_ID, crop) number of cereal units per crop rotation and field;


cereal_unit(Schlag_ID, crop) = sum((soil, size)$(Schlag_BG(Schlag_ID, soil, size) AND sum(Kommune,Location(Schlag_ID,Kommune))),
                           Yield(crop, soil, size)*GE(crop));
                           
ha_Kommune(Kommune) = sum((Schlag_ID), Schlag_ha(Schlag_ID)*Location(Schlag_ID, Kommune));
size_share(Kommune, size) = sum((soil,Schlag_ID)$Location(Schlag_ID, Kommune), Schlag_ha(Schlag_ID)*Schlag_BG(Schlag_ID,soil,size))/ha_Kommune(Kommune);
soil_share(Kommune, soil) = sum((size,Schlag_ID)$Location(Schlag_ID, Kommune), Schlag_ha(Schlag_ID)*Schlag_BG(Schlag_ID,soil,size))/ha_Kommune(Kommune);
soil_size_share(Kommune, soil, size) = sum(Schlag_ID$(Location(Schlag_ID, Kommune) and Schlag_BG(Schlag_ID,soil,size)), Schlag_ha(Schlag_ID))/ha_Kommune(Kommune);

precrop(Schlag_ID, crop) = precrop_base(Schlag_ID,crop);
Landuse(Schlag_ID,crop,'2021') = precrop(Schlag_ID,crop)$sum(Kommune,Location(Schlag_ID,Kommune));
Landuse_SQ(Kommune,crop) = sum(Schlag_ID$(precrop(Schlag_ID, crop) and Location(Schlag_ID, Kommune)), Schlag_ha(Schlag_ID));
* SO 01.08.2025: Add Landuse_SQ_base mainly for restricting set-aside area to base set aside only.
Landuse_SQ_base(Kommune, crop) = Landuse_SQ(Kommune, crop);
Landuse_SQ_crop(Kommune, kCrop) = Landuse_SQ(kommune,kCrop) + SUM(oCrop, map_konv_org(kCrop, oCrop) * Landuse_SQ(kommune,oCrop)) ;
* SO 03-12-2024 Calculate conventional grassland use in the status quo
Landuse_SQ_GL(Kommune, GHMcrop)=Landuse_SQ(Kommune, GHMcrop) + SUM(GSMcrop, map_GHM_GSM(GHMcrop, GSMcrop)*Landuse_SQ(Kommune, GSMcrop));

* MR 19.11.24
* Livestock can change during simulation, so Duenger_avail and Fodder_demand have to be calculated in optimisation-file
*Duenger_avail(Kommune, Duenger, type) = sum((ls), Livestock_SQ(Kommune, ls, type) * manure_prod(ls));
*Fodder_demand(Kommune, ls, type, comp) = Livestock_SQ(Kommune, ls, type) * Ls_dem(ls, comp) * 365;
Livestock_SQ(Kommune, ls, type) = Livestock_SQ_base(Kommune, ls, type);
Livestock_total(ls, type) = sum(Kommune, Livestock_SQ(Kommune, ls,type));
lsu(Kommune,ls,type) = Livestock_SQ(Kommune, ls, type) * ls_unit(ls);
lsu_herb(Kommune, type) = sum(ls$ls_herb(ls), Livestock_SQ(Kommune, ls, type) * ls_unit(ls));
fodder_area_sq(Kommune,type) = sum(fodder_crop$type_of_crop(fodder_crop,type), Landuse_SQ(Kommune, fodder_crop));
lsu_herb_ha(Kommune, type)$fodder_area_sq(Kommune, type) = lsu_herb(Kommune, type) / fodder_area_sq(Kommune, type);

total_area_SQ(Kommune,'all',type) = sum((crop)$type_of_crop(crop, type),Landuse_SQ(Kommune,crop));
total_area_SQ(Kommune,'arable',type) = sum((Acrop)$type_of_crop(Acrop, type),Landuse_SQ(Kommune,Acrop));
total_area_SQ(Kommune,'grassland',type) = sum((Gcrop)$type_of_crop(Gcrop, type),Landuse_SQ(Kommune,Gcrop));

org_share_SQ(Kommune, p)$total_area_SQ(Kommune, p, 'org') = total_area_SQ(Kommune, p, 'org') / sum(type, total_area_SQ(Kommune, p, type)) * 100;

* SO 10-07-2025: SQ of SNH
snh_share_SQ(Kommune, 'all') = sum(Bcrop, Landuse_SQ(Kommune, Bcrop)) / sum(type, total_area_SQ(Kommune, 'all', type)) * 100;
snh_share_SQ(Kommune, 'arable') = sum(Bcrop_arable, Landuse_SQ(Kommune, Bcrop_arable)) / sum(type, total_area_SQ(Kommune, 'arable', type)) * 100;
snh_share_SQ(Kommune, 'grassland') = sum(Bcrop_grassland, Landuse_SQ(Kommune, Bcrop_grassland)) / sum(type, total_area_SQ(Kommune, 'grassland', type)) * 100;

* SO 10-07-2025: SQ of org share in NUTS3 region
org_share_LK_SQ(p) = sum(Kommune, total_area_SQ(Kommune, p, 'org')) / sum((type, Kommune), total_area_SQ(Kommune, p, type)) * 100;

* SO 10-07-2025: SQ of SNH share in NUTS3 region
snh_share_LK_SQ('all') = sum((Bcrop, Kommune), Landuse_SQ(Kommune, Bcrop)) / sum((type, Kommune), total_area_SQ(Kommune, 'all', type)) * 100;
snh_share_LK_SQ('arable') = sum((Bcrop_arable, Kommune), Landuse_SQ(Kommune, Bcrop_arable)) / sum((type, Kommune), total_area_SQ(Kommune, 'arable', type)) * 100;
snh_share_LK_SQ('grassland') = sum((Bcrop_grassland, Kommune), Landuse_SQ(Kommune, Bcrop_grassland)) / sum((type, Kommune), total_area_SQ(Kommune, 'grassland', type)) * 100;


* SO 11-09-2025: SQ of herbivore-grassland share
lsu_herb_ha_grass_SQ(Kommune, type) =
    lsu_herb(Kommune, type)/ total_area_SQ(Kommune, 'grassland', type);
lsu_herb_ha_grass_SQ_NUTS3(type) = sum(Kommune, lsu_herb(Kommune, type))/ sum(Kommune, total_area_SQ(Kommune, 'grassland', type));
lsu_herb_ha_grass_bound(Kommune, type) = max(
 lsu_herb_ha_grass_SQ_NUTS3(type),
 lsu_herb_ha_grass_SQ(Kommune, type));

* SO 25-01-2025: Labor demand crops
lab_dem_crop(crop) = sum((soil, size, timeframe), lab_dem(crop, soil, size, timeframe));
lab_avail(Kommune, timeframe) = sum(Schlag_ID$Location(Schlag_ID, Kommune),
    sum((crop, soil, size)$Schlag_BG(Schlag_ID, soil, size), lab_dem(crop, soil, size, timeframe) * precrop(Schlag_ID, crop) * Schlag_ha(Schlag_ID)))
* MR 19.11.24 add labor that was used for animals per timeframe (half month, therefore divided by 24)
    + sum((ls,type), lab_dem_ls(ls)*Livestock_SQ(Kommune,ls,type)) / 24;
    
avg_lab_avail(Kommune) = sum(timeframe, lab_avail(Kommune, timeframe))/24;

 
lab_avail(Kommune, timeframe) = max(
    avg_lab_avail(Kommune),
    lab_avail(Kommune, timeframe));
    

vorfruchtwert_SQ(Kommune,type)$total_area_SQ(Kommune,'arable',type) =
    sum(Schlag_ID$(Location(Schlag_ID, Kommune) and not GL_ID(Schlag_ID)),
        sum(crop$(type_of_crop(crop, type) and precrop(Schlag_ID, crop)), Schlag_ha(Schlag_ID) * sum(crop2, combival_P(crop, crop2)))) / total_area_SQ(Kommune,'arable',type);
        
* MR 14-02-2025 biogas plants: calculate total demand per Kommune in dt FM
*biogas_dem(Kommune,substrate) = biogas_power_rating(Kommune) * biogas_demand(substrate)*10;

* MR 24-02-2025 change the biogas calculations
biogas_power_prod(Kommune) = biogas_installed_capa(Kommune) * 365 * 24 * biogas_util;
*biogas_dem_excreta(Kommune) = biogas_power_prod(Kommune) * share_excreta(Kommune) / power_from_excreta;
*biogas_dem_plantmat(Kommune) = biogas_power_prod(Kommune) * share_plantmat(Kommune) / power_from_plantmat;
** calculate total demand per Kommune in dt FM (therefore multiply with 10)
*biogas_dem(Kommune,substrate) = (biogas_dem_excreta(Kommune) * substrate_share(substrate)*10)$substrate_manure(substrate)
*                                + (biogas_dem_plantmat(Kommune) * substrate_share(substrate)*10)$substrate_fodder(substrate);
*

fert_eff(org_fert, Duenger) = 1;
fert_eff(org_fert, 'N') = fert_n_eff(org_fert);

parameter arable_land;
arable_land(Schlag_ID) = sum(Acrop, precrop_base(Schlag_ID, Acrop));

* SO 14-08-2025: Added to reduce price premium for organic crops
parameter of_price_premium(crop);
of_price_premium(oCrop) = Price(oCrop) - sum(kCrop, Price(kCrop) * map_konv_org(kCrop, oCrop));

parameter K_Price(crop) The conventional price for a crop;
K_Price(kCrop) = Price(kCrop);
K_Price(oCrop) =  sum(kCrop, Price(kCrop) * map_konv_org(kCrop, oCrop));