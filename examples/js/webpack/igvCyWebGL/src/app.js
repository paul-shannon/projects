cytoscape = require('cytoscape');
jquery = require('jquery');
jqueryui = require('jquery-ui')


//----------------------------------------------------------------------------------------------------
getCyOptions = function()
{
   var value = {container: $("#cyDiv"),
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
               };
    return(value);
} // getCyOptions
//----------------------------------------------------------------------------------------------------
addNetwork = function()
{
  var cyDiv = $("#cyDiv")
  return(cytoscape(getCyOptions()))
}
//----------------------------------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded',function(){
  console.log("--- document ready");
  cy = addNetwork();
   console.log("--- after addNetwork");
})

