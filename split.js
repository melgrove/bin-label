const fs = require('fs');

let geojsonObject = JSON.parse(fs.readFileSync(__dirname + '/geojson/peer_reviewed_labels_final.json', 'utf8'));

let z1Features = geojsonObject.features.filter(obj => obj.properties.Zone == '1')
let z2Features = geojsonObject.features.filter(obj => obj.properties.Zone == '2')
let z3Features = geojsonObject.features.filter(obj => obj.properties.Zone == '3')

fs.writeFileSync(__dirname + '/label-order/z1_ids.txt', z1Features.map(obj => obj.properties.Name).join('\n'));
fs.writeFileSync(__dirname + '/label-order/z2_ids.txt', z2Features.map(obj => obj.properties.Name).join('\n'));
fs.writeFileSync(__dirname + '/label-order/z3_ids.txt', z3Features.map(obj => obj.properties.Name).join('\n'));

process.exit(0)

let geojsonObject1 = Object.assign({}, geojsonObject)
geojsonObject1.features = z1Features;
let geojsonObject2 = Object.assign({}, geojsonObject)
geojsonObject2.features = z2Features;
let geojsonObject3 = Object.assign({}, geojsonObject)
geojsonObject3.features = z3Features;

fs.writeFileSync(__dirname + '/geojson/split_labels_z1.json', JSON.stringify(geojsonObject1));
fs.writeFileSync(__dirname + '/geojson/split_labels_z2.json', JSON.stringify(geojsonObject2));
fs.writeFileSync(__dirname + '/geojson/split_labels_z3.json', JSON.stringify(geojsonObject3));