const tokml = require('tokml');
const fs = require('fs');

// Command Line
// node to-kml.js <kml-file-name> <output-file-name>
const kmlFile = process.argv[2]
const outputFile = process.argv[3]
if(kmlFile === undefined || outputFile === undefined) {
    throw Error('Format: `node to-geojson.js <directory-name> <output-file-name>`')
}

let geojsonObject = JSON.parse(fs.readFileSync(__dirname + '/' + kmlFile, 'utf8'));

let kml = tokml(geojsonObject, {
    simplestyle: true,
    documentName: 'RNG Bin Labeling',
    documentDescription: 
        `
        The project is it its initial phase of development. In this phase three members of RNG will be recording bin locations and types based on the procedure in these documents: 

        Victor Stanley Labeling System: https://docs.google.com/document/d/16weyOPzB-NbNBFd3lQtPPs2vavjmYPfndcnJpWyhasE/edit

        Phase 1 Guide and Timeline: 
        https://docs.google.com/document/d/1V7yJT2pYJcA30n9fjokpxc6qY1vJjyPDdOq_OKYdOD8/edit
        `
    }
);

fs.writeFileSync(__dirname + '/' + outputFile, kml);