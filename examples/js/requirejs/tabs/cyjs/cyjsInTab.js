require.config({

    'paths': {
        'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
        'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
        //'cytoscape' :   'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cytoscape.min'
        'cytoscape': 'http://localhost:8099/cytoscape-2.7.10'
         }
   });

require(['jquery', 'jquery-ui', 'cytoscape'], function ($, ui, cytoscape) {
    var cyDiv;
    $(function(){
       console.log("--- entering onReady");
       cyDiv = $("#cyDiv");
       console.log("--- about to create window.cy");
       $("#tabs").tabs();
       setTimeout(function(){
           $("#cyDiv").text("");
           window.cy = cytoscape({container: $("#cyDiv"),
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
           }, 3000);
       }); // onready function
    }); // require
