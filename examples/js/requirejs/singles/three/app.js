require.config({
    paths: {
      'jquery': 'http://code.jquery.com/jquery-1.12.4.min',
      'three':  'https://cdnjs.cloudflare.com/ajax/libs/three.js/r79/three'
       },
    shim: {
       'three': {
          exports: 'THREE'
           },
        }
    })

require(['jquery', 'three'], function ($, THREE) {

   window.addEventListener('resize', resizeContents, false);

   function resizeContents(){
      $("#threeDiv").width(window.innerWidth * 0.98)
      $("#threeDiv").height(window.innerHeight * 0.98)
      newWidth = $("#threeDiv").width() * 0.99;
      newHeight = $("#threeDiv").height() * 0.99;
      //console.log(" window resize: " + newWidth + " x " + newHeight);
      renderer.setSize(newWidth, newHeight);
      camera.aspect = newWidth/newHeight;
      camera.updateProjectionMatrix();
      }

   var scene = new THREE.Scene();
   var camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 1000);
   camera.position.z = 10;
   var threeDiv = document.getElementById("threeDiv");
   var canvasWidth = 500;
   var canvasHeight = 500;
   var renderer = new THREE.WebGLRenderer();
   threeDiv.appendChild(renderer.domElement);
   var updateCSSStyle = false;
    renderer.setSize(canvasWidth, canvasHeight, updateCSSStyle);
   // document.body.appendChild(renderer.domElement);
   renderer.setClearColor(0xFFFFFF, 1.0);
   renderer.clear();
   
   var scatterPlot = new THREE.Object3D();
   scatterPlot.rotation.y = 0.5;
   function v(x,y,z){ return new THREE.Vector3(x,y,z); }
   
   // Draw the bounding box
   var lineGeo = new THREE.Geometry();
   lineGeo.vertices.push(
     v(-50, 50, -50), v(50, 50, -50),
     v(-50, -50, -50), v(50, -50, -50),
     v(-50, 50, 50), v(50, 50, 50),
     v(-50, -50, 50), v(50, -50, 50),
   
     v(50, -50, -50), v(50, 50, -50),
     v(-50, -50, -50), v(-50, 50, -50),
     v(50, -50, 50), v(50, 50, 50),
     v(-50, -50, 50), v(-50, 50, 50),
   
     v(50, 50, -50), v(50, 50, 50),
     v(50, -50, -50), v(50, -50, 50),
     v(-50, 50, -50), v(-50, 50, 50),
     v(-50, -50, -50), v(-50, -50, 50)
   );
   var lineMat = new THREE.LineBasicMaterial({color: 0x808080, linewidth: 1});
   var line = new THREE.Line(lineGeo, lineMat);
   line.type = THREE.Lines;
   scatterPlot.add(line);
   var mat = new THREE.PointsMaterial({vertexColors:true, size: 1.5});
   
   scene.add(scatterPlot);
   
   var light = new THREE.SpotLight();
   light.position.set( -10, 20, 16 );
   scene.add(light);
   
   
   function animate(t) {
     camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 0.1, 1000 );
     window.requestAnimationFrame(animate, renderer.domElement);
     camera.position.x = Math.sin(t/3000)*300;
     camera.position.y = 100;
     camera.position.z = Math.cos(t/3000)*300;
     camera.lookAt(scene.position);
     renderer.render(scene, camera);
     };
   
   resizeContents();
   animate(new Date().getTime());

  }); // require
