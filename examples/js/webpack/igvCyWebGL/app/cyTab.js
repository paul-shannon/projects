require.config({
   paths: {'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
           'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
           'cytoscape' :   'http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cytoscape'}
   });

//------------------------------------------------------------------------------------------------------------------------
define(['jquery', 'jquery-ui', 'cytoscape'], function ($, ui, cytoscape) {

   var self = {

      name: "cyTab",
      targetDivName: null,
      targetDiv: null,
      options: null,

      init:  function(targetDivName){
          self.options = {container: $("#cyCanvasDiv"),
                                 elements: {nodes: [{data: {id:'a'}}],
                                            edges: [{data:{source:'a', target:'a'}}]},
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
                       }; // options
          $("#cyFitButton").click(function(){self.fit(50)});
          $("#cyFitSelectedButton").click(function(){self.fitSelected(50)});
          $("#cySFNButton").click(function(){sfn()});
          $("#cyHideUnselectedButton").click(function(){cy.nodes(":unselected").hide()});
          $("#cyShowAllButton").click(function(){cy.nodes().show(); cy.edges().show()});
          $("#cyDeleteGraphButton").click(function(){self.deleteGraph()});
          $("#cyAddGraphButton").click(function(){self.addGraph()});
          }, // init

      display: function(){
         $("#cyCanvasDiv").height(800);
         self.cy = cytoscape(self.options);
         self.fit(100);
         }, // display

      loadNetworkStyleFile: function(filename){
         console.log("--- entering loadNetworkStyleFile")
         var str = window.location.href;
         var url = str.substr(0, str.lastIndexOf("/")) + "/" + filename;
         url = url.replace("/notebooks/", "/files/");
         console.log("--- loadNetworkStyleFile: " +  url);
         $.getScript(url)
            .done(function(script, textStatus) {
                console.log(textStatus);
                self.cy.style(vizmap);
                 })
            .fail(function( jqxhr, settings, exception ) {
               console.log("getScript error trying to read " + filename);
               console.log("exception: ");
               console.log(exception);
              });
         }, // loadNetworkStyleFile

        addGraph: function(jsonGraph){
           if(jsonGraph === undefined){
               //conjure up a new one
               jsonGraph = {elements:[
                              {data: {id:'a'}},
                              {data: {id:'b'}},
                              {data: {id: 'e1', source: 'a', target: 'b'}}
                             ]};
              } //if
           self.cy.json(jsonGraph);
           self.cy.fit(100);
           },
        deleteGraph: function(){
           self.cy.edges().remove();
           self.cy.nodes().remove();
           },
        fit: function(margin){
           self.cy.fit(margin);
           },
        fitSelected: function(margin){
           self.cy.fit(self.cy.nodes(":selected"), margin);
           },
       selectFirstNeighbors: function(){
          self.cy.nodes(':selected').neighborhood().nodes().select();
          },
     } // self
     return(self);
  });
//------------------------------------------------------------------------------------------------------------------------
