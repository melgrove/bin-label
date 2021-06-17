#
# This script takes the exisitng
#
#

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


