require(['app3d'], function(app3d){

   window.app3d = app3d;
   app3d.init("threeDiv");
   //var data = [{"chr":6,"pos":147596,"an":1,"af":0.9812,"EC1":0.0244},
   //            {"chr":6,"pos":148039,"an":1,"af":0.7887,"EC1":-0.1367}];
   app3d.drawScatterPlot(data3);
   app3d.animate()

   });
