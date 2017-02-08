require(['pcaTab'], function(pcaTab){

   window.pcaTab = pcaTab;
   pcaTab.init("pcaDiv");
   pcaTab.drawScatterPlot(pcaTab.demoData());
   pcaTab.animate()

   });
