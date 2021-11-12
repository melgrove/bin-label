# REA RNG Bin Labeling

## UCLA Waste Bin Data  
**Every UCLA Facilities waste bin on campus split by stream, cluster type, and ID, ordered by latitude:**
- [GeoJSON file](https://github.com/melgrove/bin-label/blob/main/geojson/peer_reviewed_labels_final.json)
- [KML file](https://github.com/melgrove/bin-label/blob/main/kml/final/peer_reviewed_labels6.kml)

**Bin identification system manual:**
- [PDF](https://raw.githubusercontent.com/melgrove/bin-label/main/Bin%20Identification%20System%20Manual.pdf)

## How to use this repository  
The repository has files with the bin data itself, and source code files used to manipulate it.  

### Bin Data
**`kml/`**: KML Files for Google Earth  
**`geojson/`**: GeoJSON Files for use in R and GIS tools  
**`label-order/`**: CSVs for the order of the printed labels 

### Code
**`main.R`**: R file used to clean data, generate IDs, and do basic GIS  
**`to-geojson.js`**: Converts KML to GeoJSON  
**`to-kml.js`**: Converts GeoJSON to KML

## Tools
*You must have Node.js installed and run `npm i` before these will work*  
  
**Convert KML to GeoJSON**  
`node to-geojson.js <directory-name | kml-file-name> <output-file-name> [--combine-dir]`
- `--combine-dir` combines all KMLs in the folder into a single GeoJSON

**Convert GeoJSON to KML**  
`node to-kml.js <geojson-file-name> <output-file-name>`
