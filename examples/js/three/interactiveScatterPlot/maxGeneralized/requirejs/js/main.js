require(['scatter3d'], function(scatter3d){
   console.log("js/main.js");
   var s3d = new scatter3d()
   console.log("asking for name of the s3d object: " + s3d.getName());
   console.log(s3d.createAxis("x", 100, "red"));
   s3d.drawScatterPlot()
   });
