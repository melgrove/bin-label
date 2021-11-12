const tj = require('@mapbox/togeojson');
const fs = require('fs');
const DOMParser = require('xmldom').DOMParser;

// Command Line
// node to-geojson.js <directory-name | geojson-file-name> <output-file-name> [--combine-dir]
const jsonDir = process.argv[2]
const outputFile = process.argv[3]
if(process.argv.includes('--combine-dir')) {
    var combineDir = true
}
if(jsonDir === undefined || outputFile === undefined) {
    throw Error('Format: `node to-geojson.js <directory-name | geojson-file-name> <output-file-name> [--combine-dir]`')
}

// convert to kml
if(combineDir) {
    var geojsonFiles = fs.readdirSync(__dirname + '/' + jsonDir)
} else {
    var geojsonFiles = [__dirname + '/' + jsonDir]
}
const convertedFiles = geojsonFiles
                    .map( name => new DOMParser().parseFromString(fs.readFileSync(__dirname + '/' + jsonDir + name, 'utf8')))
                    .map( kml => tj.kml(kml, { styles: true }).features)
                    .reduce((acc,el) => [...acc, ...el]);

// combine (w/ duplicates)
let convertedCombined = {
    type: 'FeatureCollection',
    features: convertedFiles
};

// removing duplicates
let uniqueFeatures = []
convertedCombined.features.forEach( bin => {
    if(!uniqueFeatures.map( bin => bin.id ).includes(bin.id)) {
        uniqueFeatures.push(bin);
    }
});

console.log(`Removed ${convertedCombined.features.length - uniqueFeatures.length} duplicate features`)
console.log(`Writing ${convertedCombined.features.length} features to ${__dirname + '/' + outputFile}`)

// update output and write new geojson
convertedCombined.features = uniqueFeatures
fs.writeFileSync(__dirname + '/' + outputFile, JSON.stringify(convertedCombined))
