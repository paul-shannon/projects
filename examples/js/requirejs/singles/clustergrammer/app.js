require.config({
    'paths': {
        'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
        'cytoscape' :   'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cytoscape.min'

         }
   });

require(['jquery', 'cytoscape'], function ($, cytoscape) {
    var cgDiv;
    $(function(){
       console.log("--- entering onReady");
       cgDiv = $("#cgDiv");
       console.log("--- about to create window.cy");
       window.cy = cytoscape({container: $("#cgDiv"),
                              elements:{nodes:[{data:{id:'a'}}],
                                        edges:[{data:{source:'a', target:'a'}}]},
                              style: cytoscape.stylesheet()
                                        .selector('node').style({'background-color': '#d22',
                                                                 'label': 'data(id)',
                                                                 'text-valign': 'center',
                                                                 'text-halign': 'center',
                                                                 'border-width': 1})
                                         .selector('edge').style({'line-color': 'black',
                                                                  'target-arrow-shape': 'triangle',
                                                                  'target-arrow-color': 'black',
                                                                  'curve-style': 'bezier'})
                              }); // cytoscape()
       }); // onready function
    }); // require
