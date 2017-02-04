require(['scatter3d'], function(scatter3d){
   console.log("js/main.js");
   window.s3d = new scatter3d().init("threeDiv", data)
   console.log("asking for name of the s3d object: " + window.s3d.getName());
   s3d.drawScatterPlot()
   function animate(){
      s3d.renderer.clear();
      s3d.camera.lookAt(s3d.scene.position);
      s3d.renderer.render(s3d.scene, s3d.camera);
      window.requestAnimationFrame(animate, s3d.renderer.domElement);
      }
   animate();
   });
