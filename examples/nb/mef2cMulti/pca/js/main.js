require(['pcaTab'], function(pcaTab){

   window.pcaTab = pcaTab;
    pcaTab.init("pcaDiv");
   //var data = [{"chr":6,"pos":147596,"an":1,"af":0.9812,"EC1":0.0244},
   //            {"chr":6,"pos":148039,"an":1,"af":0.7887,"EC1":-0.1367}];
   pcaTab.drawScatterPlot(data3);
   pcaTab.animate()

   });
