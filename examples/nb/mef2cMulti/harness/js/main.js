require(['../../cy/js/cyTab', '../../pca/js/pcaTab', '../../igv/js/igvTab'], function(cyTab, pcaTab, igv){

   window.cyTab = cyTab;
   cyTab.init("cyDiv");
   cyTab.display()

   window.pcaTab = pcaTab;
   pcaTab.init("pcaDiv");
   pcaTab.drawScatterPlot(pcaTab.demoData());
   pcaTab.animate()
   window.igvTab = igv;
   igvTab.init("igvDiv");
   igvTab.display();
   var tabInfo = {}
   window.xyz = tabInfo;
   var cyInitialized = false;

   function tabsCreatedOperations(){
      console.log("--- tabsCreated");
      tabInfo[0] = "igv";  // always!
      tabInfo[1] = "pca";
      tabInfo[2] = "cy";
      };

   function tabActivatedProcedures(){
      console.log("-- tabActivationProcedures");
      var indexOfActiveTab = $('#masterTabsDiv').tabs("option", "active").toString();
      console.log("now on top: " + tabInfo[indexOfActiveTab]);
      var activeTabName = tabInfo[indexOfActiveTab];
       switch(activeTabName){
         case "cy":
           if(!cyInitialized){
              cyTab.display();
              cyInitialized = true;
              }
         case "igv":
           if(!igvInitialized){
              }
           break;
         }; // switch
     } // tabActivatedProcedures

   $(document).ready(function(){
       console.log("document ready");
       $("#masterTabsDiv").tabs({
           create: tabsCreatedOperations,
           activate: tabActivatedProcedures,
           active: 0});
       });

   });
