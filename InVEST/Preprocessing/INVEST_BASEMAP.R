################################################################################
# Prepares basemap for InVEST LK
# Author: Saskia Osterkamp
# Date 26-01-2025. modified 08-07-2025
################################################################################
## ----rm cache---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rm(list=ls()) # for first time only, to save time

filepathIN <- "C:/InVEST/data_input"

{# load libraries --------------
  
  library(sf)
  library(terra)
  library(dplyr)
  library(mapview)
  library(stringr)
  # data processing
  #library(ggplot2)
}


# # ________UPLOAD INPUT LAYERS -----

start <- Sys.time()

# legend of CORINE 
legendCORINE = read.csv(paste0(filepathIN,"/Corine/CLC_legend.csv"), sep = ";")

#  (windows) This part only read in once to save time!  ----
#InVeKoS 
bw_raw <- file.path(filepathIN, "/Invekos_BW/schlag_teilschlag.gpkg")
bw_raw <- st_read(dsn=bw_raw, layer = "schlag_teilschlag_b_2021")

# municipalities
#muni_raw <- st_read(paste0(filepathIN,"/nuts/NUTS250_N3.shp"))
muni_raw <- st_read(paste0("C:/InVEST/data_input/nuts/vg250_ebenen_0101/VG250_GEM.shp"))

# CORINE land cover 
CORINELC2018_raw <- st_read(paste0(filepathIN, "/Corine/U2018_CLC2018_V2020_20u1.shp"))


# small woody features
# the tiles change depending on the area of interest 
# Reutlingen: E42N29
# Loerrach: E40N29
smf_raw <- st_read(paste0(filepathIN, "/Small_wood_features/swfBW_2018.gpkg"))


### Prepare CSR ----
# CSR: Case study region
municipalities <- st_transform(muni_raw, st_crs(bw_raw)) # shape of all municipalities of germany
# DE 141: Reutlingen
# DE 145: Alb-Donau-Kreis
# DE 119: Hohenlohekreis
CSR <- subset(municipalities, municipalities$"NUTS" == "DE119")

# Merge all municipalities into one multipolygon (i.e., dissolve boundaries)
CSR_merged <- st_union(CSR)

# Get the outer boundary (line)
CSR_boundary <- st_boundary(CSR_merged)

# Create 1 km (1000 m) buffer around the boundary line
buffer_1km <- st_buffer(CSR_boundary, dist = 1000)

CSR_buffered <- st_union(CSR_merged, buffer_1km)

# Plot to verify
plot(st_geometry(CSR), border = 'black', main = "1km Buffer Around CSR Border")
plot(st_geometry(buffer_1km), col = rgb(1, 0, 0, 0.5), add = TRUE)
plot(CSR_buffered, col = 'lightblue', main = "NUTS3 Region + 1km Buffer")


#________LAYER PREPARATION  ----

# INVEKOS data BW original ####

# transform coordinate system
system.time({bw_proj <- st_transform(bw_raw, st_crs(CSR))})

# intersect case study with InVeKoS/PALUD output #
system.time({bw_small <- st_intersection(bw_proj, CSR)})

# filter permantent crops
permanent_crops <- c(49, 54, 55, 70, 71, 72, 73, 75, 76, 77, 112, 115, 116, 121, 
                     131, 132, 143, 171, 172, 210, 311, 320, 321, 330, 422, 452, 
                     481, 556, 564, 590, 591, 602, 603, 610, 707, 821, 827, 829, 
                     843, 844, 848, 930, 991, 995)
bw1 <- bw_small %>% filter(nc %in% sprintf("%04d", permanent_crops))

# column cleaning
bw1 <- bw1[,c("nc")]
bw1 <- bw1[!is.na(bw1$nc),]

# add "INV" as identifier to nc column
bw2 <- dplyr::select(bw1, "nc")
bw2$nc2 <- paste0(bw2$nc,"INV")
invekos_small <- bw2 %>%
  dplyr::select("nc2") %>%
  rename("nc" = "nc2", "geometry" = "geom")

mapview(invekos_small)


### Add SWF ----

# transform coordinate system
system.time({smf_proj <- st_transform(smf_raw, st_crs(CSR))})

# crop SWF to study region
system.time({smf_crop <- st_intersection(smf_proj,CSR_buffered)})

# Add "COP3001" as identifier to nc column
smf_crop$nc <- "COP3001"
smf_crop <- dplyr::select(smf_crop, "nc")
smf_crop2 <- st_set_geometry(smf_crop, "geometry")

#  keep the SWF polygons within the wholes of the polygons from InVeKoS
system.time({swf2 <- st_difference(smf_crop2,st_union(invekos_small))}) 
invekos_swf <- rbind(swf2,invekos_small)

mapview(invekos_swf)

### Add CORINE ----

# add legend to LC codes
legendCORINE$CLC_CODE <- as.character(legendCORINE$CLC_CODE)
CORINELC2018 <- CORINELC2018_raw %>% left_join(legendCORINE[, c("CLC_CODE", "LABEL3")], by = c("Code_18" = "CLC_CODE"))

# transform CORINE to CRS of InVeKoS
system.time({CORINELC2018 <- st_transform(CORINELC2018, st_crs(CSR))})

# intersect case study area with CORINE
system.time({corine_CSR <- st_intersection(CORINELC2018, CSR_buffered)})

# Add "COR" as identifier
corine_CSR$nc<- paste0(corine_CSR$Code_18, "COR")

# column cleaning
cor1 <- dplyr::select(corine_CSR, "nc")

# keep the CORINE polygons within the wholes of the polygons from InVeKoS
system.time({cor2 <- st_difference(cor1,st_union(invekos_swf))}) 
invekos_swf_cor <- rbind(invekos_swf,cor2)
mapview(invekos_swf_cor)

### Save BASEMAP for InVEST ----
st_write(invekos_swf_cor, "C:/InVEST/data_input/BASEMAP_InVEST_Hohenlohe.shp", append = FALSE)
