import css from './css/style.css';
var cytoscape = require('cytoscape');
$("#cyDiv").height(1000);
var bootstrapLoader = require('bootstrap-loader');
var network = require("./data/cellphoneModel.json")
var vizmap  = require("./data/networkStyle.json")
var tinyApp = require("./tinyApp.js")
var menus = require("./menus.js")
menus.init();
var firstSelectedNode = null;

var cy = cytoscape({container: $("#cyDiv"),
                    elements: network.elements,
                    layout: {name: "preset", fit: true},
                    style: vizmap,
                    ready: function(){
                      cy = this;
                      cy.on("select", function(event){
                         if(cy.nodes(":selected").length == 1){
                            firstSelectedNode = event.target.id();
                            }
                         tinyApp.enableDisableMenusBasedOnSelectedNodeCount(cy);
                         });
                     cy.on("unselect", function(){
                       tinyApp.enableDisableMenusBasedOnSelectedNodeCount(cy);
                       });
                    console.log("small cy network ready, with " + cy.nodes().length + " nodes.");
                   cy.fit(50);
                   } // ready
               }); // cytoscape ctor

tinyApp.init(network)
$(window).resize(tinyApp.handleWindowResize);
tinyApp.handleWindowResize();
tinyApp.setupMenus(cy);
window.cy = cy;


