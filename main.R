# Init
if(!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("dkahle/ggmap", ref = "tidyup", force=TRUE)
library(tidyverse)
library(geojsonio)
library(sp)
library(ggmap)
library(sf)
library(geojsonsf)

# This is an API Key to use Google Maps in R. You can get one yourself from
# Google or ask me for mine. I didn't include it in the file because it
# costs money to use and I don't know who will be using this file in the future
# - Oliver
ggmap::register_google("AIzaSyCKFuWElFtWdo5Dk6RJN-XhJnu-aCLMXmw")

# Parse GeoJSON
root_dir <- dirname(sys.frame(1)$ofile)
fileName = paste0(root_dir, '/geojson/combined.json')
geojsonText = readChar(fileName, file.info(fileName)$size)
sf <- geojson_sf(geojsonText)

# Data Cleaning
  # xxxxFR' -> xxxxFR
sf$name[sf$name == "xxxxFR'"] <- "xxxxFR"
  # xxxxAL (small) -> xxxxAS
sf$name[sf$name == "xxxxAL(small)"] <- "xxxxAL"

# Separate Bins from Zones
zoneIndices <- which(sf$geometry %>% sapply(function(x) class(x)[2]) == 'POLYGON')
zones <- sf$geometry[zoneIndices]
bins <- sf$geometry[-zoneIndices]

# Long / Lat / Name  
bins_names_vec <- sf$name[-zoneIndices]
bins_long_vec <- bins %>% map_dbl(~ .[1])
bins_lat_vec <- bins %>% map_dbl(~ .[2])

# Zone data frames
zone_polygons <- map(zoneIndices, ~ data.frame(x=sf$geometry[[.]][[1]][,1], y=sf$geometry[[.]][[1]][,2]))

# Bins in Zone n Indices
bin_indices_in_zone <- map(zoneIndices[1:3], ~ which(sapply(st_within(bins, sf$geometry[[.]]), function(x) length(x) == 1)))

# Bins in Zone 3 Subzone n Indices
bin_indices_in_zone3_subzone <- map(zoneIndices[4:7], ~ which(sapply(st_within(bins, sf$geometry[[.]]), function(x) length(x) == 1)))

# Long, Lat, (XXXXFL) Name
bin_df <- data.frame(
  long=bins_long_vec, 
  lat=bins_lat_vec, 
  chars=str_sub(bins_names_vec, -2),
  stream_char=str_sub(bins_names_vec, -1),
  zone_num=integer(length(bins)), 
  bin_num=integer(length(bins))
)

stream <- character(nrow(bin_df))
stream[bin_df$stream == 'C'] <- 'Compost'
stream[bin_df$stream == 'R'] <- 'Recycle'
stream[bin_df$stream == 'L'] <- 'Landfill'
bin_df <- cbind(bin_df, stream)

# Generate IDs
  # Set non-edge case zones
for(n in 1:3) {
  bin_df$zone_num[bin_indices_in_zone[[n]]] <- n
}
no_zone_bin_df <- bin_df %>% filter(zone_num == 0)
no_zone_bin_indices <- which(bin_df$zone_num == 0)

  # Manually set zones for edge cases
manual_1 <- c() 
manual_2 <- c(no_zone_bin_indices[1:19])
manual_3 <- c(no_zone_bin_indices[20:33])
bin_df$zone_num[manual_2] <- 2
bin_df$zone_num[manual_3] <- 3

  # Generate full IDs
bin_df_z1 <- bin_df %>% filter(zone_num == 1)
bin_df_z2 <- bin_df %>% filter(zone_num == 2)
bin_df_z3 <- bin_df %>% filter(zone_num == 3)
bin_df_z1$bin_num[order(bin_df_z1$lat)] <- seq_along(bin_df_z1$lat)
bin_df_z2$bin_num[order(bin_df_z2$lat)] <- seq_along(bin_df_z2$lat)
bin_df_z3$bin_num[order(bin_df_z3$lat)] <- seq_along(bin_df_z3$lat)

bin_df <- rbind(bin_df_z1, bin_df_z2, bin_df_z3)
bin_df$bin_num <- formatC(bin_df$bin_num, width=3, flag="0")
bin_df <- bin_df %>% mutate(name = paste0(zone_num, bin_num, chars))

# Zone Polygon Dataframe
zone_df <- data.frame(x=zones[1:3][[1]][[1]][,1], y=zones[1:3][[1]][[1]][,2], zone_num=1)
zone_df <- rbind(zone_df, data.frame(x=zones[1:3][[2]][[1]][,1], y=zones[1:3][[2]][[1]][,2], zone_num=2))
zone_df <- rbind(zone_df, data.frame(x=zones[1:3][[3]][[1]][,1], y=zones[1:3][[3]][[1]][,2], zone_num=3))

# Get ID list for Google Doc
zone1_bin_ids <- bin_df %>% filter(zone_num == 1)
zone1_bin_ids <- zone1_bin_ids[order((zone1_bin_ids %>% filter(zone_num == 1))$lat),] %>% select(name)
zone1_bin_ids <- zone1_bin_ids %>% mutate(zone = 1)
rownames(zone1_bin_ids) <- seq_along(zone1_bin_ids$name)

zone2_bin_ids <- bin_df %>% filter(zone_num == 2)
zone2_bin_ids <- zone2_bin_ids[order((zone2_bin_ids %>% filter(zone_num == 2))$lat),] %>% select(name)
zone2_bin_ids <- zone2_bin_ids %>% mutate(zone = 2)
rownames(zone2_bin_ids) <- seq_along(zone2_bin_ids$name)

zone3_bin_ids <- bin_df %>% filter(zone_num == 3)
zone3_bin_ids <- zone3_bin_ids[order((zone3_bin_ids %>% filter(zone_num == 3))$lat),] %>% select(name)
zone3_bin_ids <- zone3_bin_ids %>% mutate(zone = 3)
rownames(zone3_bin_ids) <- seq_along(zone3_bin_ids$name)

ordered_bin_ids <- zone1_bin_ids %>% 
                      dplyr::union(zone2_bin_ids) %>% 
                      dplyr::union(zone3_bin_ids)

# Convert to bin_df to sf
projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
sf_new <- st_as_sf(x = bin_df %>% select(long, lat, name, stream),                         
               coords = c("long", "lat"),
               crs = projcrs)

# Export GeoJSON
st_write(sf_new, dsn = paste0(root_dir, "/geojson/generated_labels5.json"), driver = "GeoJSON")

# Export Bin ID CSV
write_csv(sf_new %>% transmute('Bin ID' = name, 'Stream'=stream), paste0(root_dir, "/label-order/binIDs1.csv"))
write_csv(ordered_bin_ids, paste0(root_dir, "/label-order/binIDs2.csv"))


stop('Stop before mapping')
# Mapping
  # Base Terrain from Google
p <- ggmap(get_googlemap(center = c(Longitude = -118.431, Latitude = 34.073),
                         zoom = 17, scale = 2,
                         maptype ='satellite',
                         color = 'color'))

  # Layers
    # Bin Points
p + geom_point(aes(x=long, y=lat, color=stream), data = not_found, size=2.5) 
    #geom_polygon(aes(x=x, y=y), fill='green', alpha=0.4, zone_df %>% filter(zone_num == 1)) +
    #geom_polygon(aes(x=x, y=y), fill='red', alpha=0.4, zone_df %>% filter(zone_num == 2)) +
    #geom_polygon(aes(x=x, y=y), fill='blue', alpha=0.4, zone_df %>% filter(zone_num == 3))
    # Zone 2 points
p + geom_point(aes(x=x, y=y, group=zone_num), data = zone2, size=1)

    # Density
p + stat_density2d(
  aes(x=x, y=y, fill = 'green', alpha = 0),
  sizess = .2, alpha=0.2, bins = 8, data = bin_coords_df[stream == 'Compost',],
  geom = "polygon", color = 'black'
  ) +
  scale_fill_manual(values = c('green')) +
  ylim(c(34.063, 34.078)) +
  xlim(c(-118.45, -118.437)) +
  coord_fixed()+ geom_point(aes(x=x, y=y, color=stream), data = bin_coords_df, size=1) +
  scale_color_manual(values = c("Compost" = "green", "Recycle" = "blue", "Landfill" = "brown"))