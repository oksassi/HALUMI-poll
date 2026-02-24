# Install and load the required packages
# install.packages("sf")
# install.packages("openxlsx")
# install.packages("stringi")
library(sf)
library(openxlsx)
library(stringi)
library(dplyr)
library(mapview)

# Set wd
#setwd("C:/git/BEATLE/PALUD/PALUD_fieldscale/PALUD_fieldscale/Muensingen")
setwd("C:/git/BEATLE/PALUD/PALUD_org_Saskia")

# set model type
model_type <- "org"

# Read the shapefile
shapefile <- st_read("C:/git/InVeKoS_Sponagel.shp")
colnames(shapefile)
# head(shapefile)
unique(shapefile$D2)

# Filter shapefile
# With grassland for PALUD_org, without grassland for PALUD
#shapefile_filtered <- subset(shapefile, Flchnrt == "Ackerland" & NUTS_NA == "Lörrach")
shapefile_filtered <- subset(shapefile, Flchnrt == "Ackerland" | Flchnrt == "Gruenland")
unique(shapefile_filtered$NUTS_NA)
unique(shapefile_filtered$NUTS_CO)
# Save geometry
shapefile_filtered <- shapefile_filtered %>%  rename(Schlag_ID = Schl_ID)
shapes <- shapefile_filtered %>% select(c(Schlag_ID, geometry))

# Keep the attribute data
shapefile_df <- as.data.frame(shapefile_filtered)

# Drop the geometry column if it exists as a list
shapefile_df <- st_drop_geometry(shapefile_df)

df <- data.frame(
  Schlag_ID = numeric(nrow(shapefile_df)),
  AGS = numeric(nrow(shapefile_df)),
  NAME = character(nrow(shapefile_df)),
  NUTS_CODE = numeric(nrow(shapefile_df)),
  NUTS_NAME = character(nrow(shapefile_df)),
  SOIL = character(nrow(shapefile_df)),
  SIZE = numeric(nrow(shapefile_df)),
  AREA = numeric(nrow(shapefile_df)),
  REGBEZ = character(nrow(shapefile_df)),
  REGBEZNR = numeric(nrow(shapefile_df)),
  K_PALUD = character(nrow(shapefile_df)),
  n = numeric(nrow(shapefile_df)),
  FL_ART = character(nrow(shapefile_df)),
  NC = numeric(nrow(shapefile_df)),
  NUTZUNG = character(nrow(shapefile_df)),
  ORGANIC = logical(nrow(shapefile_df))
)

df$Schlag_ID <- shapefile_df$Schlag_ID
df$AGS <- shapefile_df$SCHLUES
df$NAME <- stri_trans_general(shapefile_df$NAME, "Latin-ASCII")
df$NUTS_CODE <- shapefile_df$NUTS_CO
df$NUTS_NAME <- stri_trans_general(shapefile_df$NUTS_NA, "Latin-ASCII")
df$SOIL <- shapefile_df$Soil
df$SIZE <- shapefile_df$Size
df$AREA <- shapefile_df$FLAECHE
df$REGBEZNR <- substr(shapefile_filtered$NUTS_CO, 1,4)
# Assign Regbez
regbez_map <- c("DE11" = "Stuttgart", "DE12" = "Karlsruhe", 
                "DE13" = "Freiburg", "DE14" = "Tubingen")
df$REGBEZ <- regbez_map[df$REGBEZNR]
df$n <- 1
# if organic
if(model_type == "org"){
  df$ORGANIC <- shapefile_df$D2
  df$K_PALUD <- shapefile_df$K_PALUD
  df$K_PALUD <- ifelse(df$K_PALUD == "Gras", "GSM", df$K_PALUD)
  df$K_PALUD <- ifelse(is.na(df$ORGANIC) & !is.na(df$K_PALUD), df$K_PALUD, paste0("o", df$K_PALUD)) 
} else{
  df$K_PALUD <- shapefile_df$K_PALUD
}
df$FL_ART <- stri_trans_general(shapefile_df$Flchnrt, "Latin-ASCII")
df$NC <- shapefile_df$NUTZCOD
unique(df$K_PALUD)

#df$NUTZUNG <- stri_trans_general(shapefile_df$Region, "Latin-ASCII")
#sort(unique(df$AGS))
#unique(df$REGBEZNR)
#unique(df$AGS[df$NUTS_NAME == "Reutlingen"])
#unique(df$AGS[df$NAME == "Munsingen"])


head(df)
#sumarea <- df %>% group_by(K_PALUD) %>% summarize(SUM= sum(AREA))

# Write to Excel file
write.xlsx(df, "./Input/InVeKoS_Sponagel_org.xlsx", sheetName = "Sheet1", append=FALSE)

# Also save shapefile
sf_object <- merge(x = shapes, y = df, by = "Schlag_ID")
st_write(sf_object, 
         "./Input/InVeKoS_shapefile_org.shp", 
         append = FALSE)


### Save also Land_ID, Kommunen_ID & LK_ID

AGS <- sort(unique(df$AGS))
# write csv file Kommunen_ID
write.table(AGS, "Input/Kommunen_ID.csv", row.names = FALSE, col.names=FALSE, append=FALSE)

Schlag_ID <- sort(unique(df$Schlag_ID))
# write csv file Land_ID
write.table(Schlag_ID, "Input/Land_ID.csv", row.names = FALSE, col.names=FALSE, append=FALSE)

LK_ID <- sort(unique(df$NUTS_CODE))
# write csv file LK_ID
write.table(LK_ID, "Input/LK_ID.csv", row.names = FALSE, col.names=FALSE, append=FALSE)

RP_ID <- sort(unique(df$REGBEZNR))
# write csv file RP_ID
write.table(RP_ID, "Input/RP_ID.csv", row.names = FALSE, col.names=FALSE, append=FALSE)

---------------------------
# --- RUN GAMS MODEL ---
---------------------------
# Set wd
#setwd("C:/git/BEATLE/PALUD/PALUD_fieldscale/PALUD_fieldscale/Muensingen")
setwd("C:/git/BEATLE/PALUD/PALUD_aggregated")
# 
# # set model type
model_type <- "org"
#model_type <- ""
year <- "2030"
suffix <- ""
output_filename <- paste0("PALUD_shapefile", suffix, year)
  
library(sf)
library(openxlsx)
library(readxl)
library(stringi)
library(dplyr)
library(mapview)

# reconvert xlsx to shp
getwd()  

# read shapefile
#sf <- st_read("./Input/InVeKoS_shapefile.shp")
# org:
#sf <- st_read("./Input/Reutlingen_2020.shp")
#sf <- st_read(dsn="B:/beatle/InVeKoS_Datenharmonisierung/InVeKoS_Datenharmonisierung/InVeKoS_Datenharmonisierung/InVeKoS_BW (08)/Daten_Baden-Württemberg (BW - 08)/AVA-735/schlag_teilschlag.gpkg", 
#              layer = "schlag_teilschlag_b_2021")
sf <- st_read("B:/beatle/InVeKoS_Datenharmonisierung/InVeKoS_Datenharmonisierung/InVeKoS_Datenharmonisierung/InVeKoS_BW (08)/BW_2021/BW_2021_shapefile/BW_2021.shp")
head(sf)
sf <- mutate(sf, Schl_ID =  row_number())

# Read the Excel file
#df2 <- read.xlsx("C:/git/BEATLE/PALUD/PALUD_fieldscale/PALUD_fieldscale/Loerrach/InVeKoS_Sponagel.xlsx")
#df2 <- read_excel("C:/git/BEATLE/PALUD/PALUD_org_Saskia/Output/fields.xlsx")
df2 <- read.xlsx(paste0("./Output/fields", suffix, ".xlsx"))
head(df2)
unique(df2$Year)

# Update Schlag_ID by replacing "12021" with "08.2021."
df2$Schlag_ID <- gsub("12021", "", df2$Schlag_ID)

# # Read PALUD Input file
# plots <- read.xlsx("./Input/New_Plots_BW.xlsx")
# head(plots)
# unique(plots$AGS)
# munsingen <- plots %>% subset(plots$AGS == "08415053")
# head(munsingen)

# Input stimmt
df2 <- df2 %>% subset(df2$Year == year)
df2 <- df2 %>% select(-Year)
sf2 <- sf %>% select(-c(PALUD, KLUTGRUPP, FAKT_CODE, OEVF_CODE))
#  sf2 <- sf %>% select(-c(K_PALUD, Kltrgrp, FAKT_CO, OEVF_CO))
sf2$REGBEZ <- "Tubingen"
sf2$REGBEZNR <- 3
# Step 1: Extract the part after the last dot and convert to numeric
sf2$Schlag_ID <- as.numeric(sub(".*\\.", "", sf2$Schl_ID))
# Step 2: Subset the rows where Schlag_ID matches any value in PALUD output
subset_sf <- sf2[sf2$Schlag_ID %in% df2$Schlag_ID, ]
head(subset_sf)
subset_sf <- subset_sf %>% select(-"SCHLAG_ID")
#mapview(subset_sf)
df3 <- df2 %>% select(-c(AGS))
sf_object2 <- merge(x=subset_sf, y = df3, by = "Schlag_ID")
head(sf_object2)
sf_object2 <- sf_object2[, c(1, 6:9, 4,5, 3, 15:18, 13, 11,12,19)]
colnames(sf_object2) <- c("Schlag_ID", "AGS", "NAME", "NUTS_CODE",  "NUTS_NAME",
                          "SOIL", "SIZE", "AREA", "REGBEZ", "REGBEZNR", "K_PALUD", "n", "FL_ART", "NC", 
                          "NUTZUNG", "geometry") 
st_geometry(sf_object2) <- "geometry"
mapview(sf_object2)


if(model_type == "org"){
  sf_object2$NC <- as.character(sf_object2$NC)
  sf_object2 <- sf_object2 %>%
    mutate(NC = case_when(
      K_PALUD == "Erd" ~ "707",
      K_PALUD == "SO" ~ "320",
      K_PALUD == "B" ~ "591",
      K_PALUD == "BL" ~ "590",
      K_PALUD == "GE" ~ "610",
      K_PALUD == "Ha" ~ "143",
      K_PALUD == "KG" ~ "422",
      K_PALUD == "Ka" ~ "602",
      K_PALUD == "KL" ~ "210",
      K_PALUD == "KM" ~ "171",
      K_PALUD == "Rog" ~ "121",
      K_PALUD == "SG" ~ "132",
      K_PALUD == "SJ" ~ "330",
      K_PALUD == "SM" ~ "172",
      K_PALUD == "Som" ~ "116",
      K_PALUD == "WG" ~ "131",
      K_PALUD == "Win" ~ "112",
      K_PALUD == "WR" ~ "311",
      K_PALUD == "WW" ~ "115",
      K_PALUD == "SB" ~ "321",
      K_PALUD == "ZR" ~ "603",
      K_PALUD == "GSM" ~ "452",
      K_PALUD == "GHM" ~ "452",
      K_PALUD == "BG" ~ "591",
      K_PALUD == "oErd" ~ "707o",
      K_PALUD == "oSO" ~ "320o",
      K_PALUD == "oB" ~ "591o",
      K_PALUD == "oBL" ~ "590o",      
      K_PALUD == "oGE" ~ "610o",
      K_PALUD == "oHa" ~ "143o",
      K_PALUD == "oKG" ~ "422o",
      K_PALUD == "oKa" ~ "602o",
      K_PALUD == "oKL" ~ "210o",
      K_PALUD == "oKM" ~ "171o",
      K_PALUD == "oRog" ~ "121o",
      K_PALUD == "oSG" ~ "132o",
      K_PALUD == "oSJ" ~ "330o",
      K_PALUD == "oSM" ~ "172o",
      K_PALUD == "oSom" ~ "116o",
      K_PALUD == "oWG" ~ "131o",
      K_PALUD == "oWin" ~ "112o",
      K_PALUD == "oWR" ~ "311o",
      K_PALUD == "oWW" ~ "115o",
      K_PALUD == "oSB" ~ "321o",
      K_PALUD == "oZR" ~ "603o",
      K_PALUD == "oGSM" ~ "452o",
      K_PALUD == "oGHM" ~ "452o",
      K_PALUD == "oBG" ~ "591o",
      TRUE ~ "NA"  # Assign NA for any unmatched values
    ))
}      

# # Save as shapefile
# st_write(sf_object2, 
#          paste0("./Output/", output_filename, ".shp"), 
#          append = FALSE)

st_write(sf_object2, 
         paste0("C:/git/BEATLE/InVEST/data_input/Invekos_BW", output_filename, ".shp"), 
         append = FALSE)

# st_write(sf_object2, 
#          paste0("C:/InVEST/data_input/Invekos_BW/", output_filename, ".shp"), 
#          append = FALSE)