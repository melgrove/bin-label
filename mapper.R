# Init
if(!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("dkahle/ggmap", ref = "tidyup", force=TRUE)
library(tidyverse)
library(geojsonio)
library(sp)
library(ggmap)
library(sf)
library(geojsonsf)
ggmap::register_google("AIzaSyCKFuWElFtWdo5Dk6RJN-XhJnu-aCLMXmw")

# Parse GeoJSON
root_dir <- dirname(sys.frame(1)$ofile)
fileName = paste0(root_dir, '/geojson/combined.json')
geojsonText = readChar(fileName, file.info(fileName)$size)
sf <- geojson_sf(geojsonText)

bins <- geojson_read(fileName)
bin_index <- sapply(bins$features, function(x) x$geometry$type) == 'Point'  
only_bins <- bins$features[bin_index]

# Separate Bins from Zones
"Zones:"
(zoneIndices <- which(sf$geometry %>% sapply(function(x) class(x)[2]) == 'POLYGON'))
bins2 <- sf$geometry[-zoneIndices]
zones <- sf$geometry[zoneIndices]

# Zone data frames
zone1 <- data.frame(x=sf$geometry[[327]][[1]][,1], y=sf$geometry[[327]][[1]][,2])
zone2 <- data.frame(x=sf$geometry[[328]][[1]][,1], y=sf$geometry[[328]][[1]][,2])
zone3 <- data.frame(x=sf$geometry[[329]][[1]][,1], y=sf$geometry[[329]][[1]][,2])
zone3_subzone1 <- data.frame(x=sf$geometry[[447]][[1]][,1], y=sf$geometry[[447]][[1]][,2])
zone3_subzone2 <- data.frame(x=sf$geometry[[456]][[1]][,1], y=sf$geometry[[456]][[1]][,2])
zone3_subzone3 <- data.frame(x=sf$geometry[[457]][[1]][,1], y=sf$geometry[[457]][[1]][,2])
zone3_subzone4 <- data.frame(x=sf$geometry[[491]][[1]][,1], y=sf$geometry[[491]][[1]][,2])

# Bins in Zone n Indices
bin_indices_in_zone <- map(c(327, 328, 329), ~ sapply(st_within(bins, sf$geometry[[.]]), function(x) length(x) == 1))

# Bins in Zone 3 Subzone n Indices
bin_indices_in_zone3_subzone <- map(c(447, 456, 457, 491), ~ sapply(st_within(bins, sf$geometry[[.]]), function(x) length(x) == 1))

# Long, Lat, (XXXXFL) Name
bin_coords <- only_bins %>%
                lapply(function(f) c(f$geometry$coordinates[[1]][1], f$geometry$coordinates[[2]][1], f$properties$name[1]))

# Data Cleaning / Formatting
  # Fix ')' mistype
bin_coords[[359]][3] <- 'xxxxFR'
stream <- vector(mode="character", length = length(bin_coords))
'Unique Bin IDs:'
(unique_ids <- unique(unlist(bin_coords[3])))
stream[bin_coords %>% sapply(function(x) str_sub(x[3], start=-1) == 'L')] <- 'Landfill'
stream[bin_coords %>% sapply(function(x) str_sub(x[3], start=-1) == 'R')] <- 'Recycle'
stream[bin_coords %>% sapply(function(x) str_sub(x[3], start=-1) %in% c('C', ')'))] <- 'Compost'
stream <- as.factor(stream)
  # Format into data frame from ggplot
bin_coords_df <- data.frame(x = as.numeric(sapply(bin_coords, function(x) x[1])), y = as.numeric(sapply(bin_coords, function(x) x[2])))

# Base Terrain
p <- ggmap(get_googlemap(center = c(lon = -118.4436, lat = 34.07),
                         zoom = 15, scale = 2,
                         maptype ='terrain',
                         color = 'color'))


# Layers
  # Bin Points
p + geom_point(aes(x=x, y=y, color=stream), data = bin_coords_df, size=1) +
  scale_color_manual(values = c("Compost" = "green", "Recycle" = "blue", "Landfill" = "brown"))

  # Zone 2 points
p + geom_point(aes(x=x, y=y), data = zone2, size=1)

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
