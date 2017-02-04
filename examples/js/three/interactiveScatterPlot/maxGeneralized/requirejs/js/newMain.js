require(['app3d'], function(app3d){

   window.app3d = app3d;
   app3d.init("threeDiv");
   app3d.drawScatterPlot(data);
   app3d.animate()

   });
