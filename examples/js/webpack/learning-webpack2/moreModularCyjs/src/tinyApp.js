// tinyApp.js

var sfnButton = null;

module.exports = {


    init: function(){
       console.log("hello fromm tinyApp.init");
       },

    handleWindowResize: function(){
        var outermostDivHeight = $("#outermostDiv").height();
        var menubarHeight = $("#menubarDiv").height();
        var newHeight = outermostDivHeight - (menubarHeight + 20);
        $("#cyDiv").height(newHeight)
        },

    selectShortestPath: function() {
       var selectedNodes = cy.nodes(":selected");
       if(selectedNodes.length != 2){
          return;
          }

        var selectedNodesIDs = selectedNodes.map(function(obj){return obj.id()});
        var rootNode = window.singleSelectedNode;
        var rootNodeID = rootNode[0].id();
        var rootNodeIndex = selectedNodesIDs.indexOf(rootNodeID);
        var targetNodeIndex = 1;
        if(rootNodeIndex == 1){
           targetNodeIndex = 0;  // just two possibilities, 0 or 1
           }
        var targetNode = selectedNodes[targetNodeIndex]
        var d = cy.elements().dijkstra({root: rootNode, directed: true});
        var path = d.pathTo(targetNode)
        var nodesInPath = path.nodes();
        nodesInPath.select()
        var max = nodesInPath.length - 1;
        for(var i=0; i < max; i++){
            nodesInPath[i].edgesTo(nodesInPath[i+1]).select();
           } // for i
        }, // selectShortestPath

    setupMenus: function(cy){
       knockoutButton = $("#knockoutButton");
       knockoutButton.prop('disabled', true);
       knockoutButton.click(function(){});

       restoreButton = $("#restoreButton");
       restoreButton.prop('disabled', true);
       restoreButton.click(function(){});

       phoneTreeButton = $("#phoneTreeButton");
       phoneTreeButton.prop('disabled', true);
       phoneTreeButton.click(function(){});

       shortestPathButton = $("#shortestPathButton");
       shortestPathButton.prop('disabled', false);
       shortestPathButton.click(this.selectShortestPath);

       resetGraphButton = $("#resetGraphButton");
       resetGraphButton.prop('disabled', false);
        resetGraphButton.click(function(){cy.edges().show(); cy.nodes().show()});

       helpButton = $("#helpButton");
       helpButton.click(function(){});

       fitButton = $("#fitButton");
       fitButton.click(function(){cy.fit(50)});

       fitSelectedButton = $("#fitSelectedButton");
       fitSelectedButton.prop('disabled', false);

       fitSelectedButton.click(function(){
         var selectedNodes = cy.filter('node:selected');
         if(selectedNodes.length > 0){
           cy.fit(selectedNodes, 50)
           }});

       clearSelectionsButton = $("#clearSelectionsButton");
       clearSelectionsButton.prop('disabled', true);
       clearSelectionsButton.click(function(){
          cy.nodes(":selected").unselect()
          cy.edges(":selected").unselect()
          });

       sfnButton = $("#sfnButton");
       sfnButton.prop('disabled', true);
       sfnButton.click(function(){cy.nodes(":selected").outgoers().targets().select()});
       }, // setupMenus

    enableDisableMenusBasedOnSelectedNodeCount: function(cy){
       var selectedNodeCount = cy.nodes(":selected").length
        if(selectedNodeCount > 0){
          clearSelectionsButton.prop('disabled', false);
          sfnButton.prop("disabled", false);
          }
       switch(selectedNodeCount){
          case 0:
             window.singleSelectedNode = null;
             sfnButton.prop("disabled", true);
             break;
          case 1:
             window.singleSelectedNode = cy.nodes(":selected").map(function(obj){return obj});
             sfnButton.prop("disabled", false);
             break;
          case 2:
             // turn on the "shortest path" button
             break;
          default:  // > 2 nodes selected
             window.singleSelectedNode = null;
           } // switch on selectedNodeCount
       } // enableDisableMenusBasedOnSelectedNodeCount



} // module.exports

