import css from './style.css';
document.write(require("./content.js"));
var cytoscape = require('cytoscape');
console.log(cytoscape);
$("#cyDiv").height(300);
var network = require("./cellphoneModel.json")
var vizmap  = require("./networkStyle.json")
//var cy = cytoscape({container: $("#cyDiv"), elements:{nodes:[{data:{id:'a'}}], edges:[{data:{source:'a', target:'a'}}]}})
var cy = cytoscape({container: $("#cyDiv"),
                    elements: network.elements,
                    layout: {name: "preset", fit: true},
                    style: vizmap});
window.cy = cy;


