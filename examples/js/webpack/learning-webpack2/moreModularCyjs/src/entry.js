import css from './css/style.css';
document.write(require("./content.js"));
var cytoscape = require('cytoscape');
$("#cyDiv").height(1000);
var network = require("./data/cellphoneModel.json")
var vizmap  = require("./data/networkStyle.json")
var cy = cytoscape({container: $("#cyDiv"),
                    elements: network.elements,
                    layout: {name: "preset", fit: true},
                    style: vizmap});
window.cy = cy;


