import css from './css/style.css';
var cytoscape = require('cytoscape');
$("#cyDiv").height(1000);
var bootstrapLoader = require('bootstrap-loader');
var network = require("./data/cellphoneModel.json")
var vizmap  = require("./data/networkStyle.json")
var cy = cytoscape({container: $("#cyDiv"),
                    elements: network.elements,
                    layout: {name: "preset", fit: true},
                    style: vizmap});
var tinyApp = require("./tinyApp.js")
tinyApp.init()
$(window).resize(tinyApp.handleWindowResize);
window.cy = cy;


