require.config({
   paths: {'three':   'https://cdnjs.cloudflare.com/ajax/libs/three.js/r83/three'},
   shim:  {'three':   {'exports': 'THREE'}}
   });

//------------------------------------------------------------------------------------------------------------------------
define(['three'], function (THREE) {

   var self = function(){

      var name = 'scatter3d';

      //----------------------------------------------------------------------------------------------------
      this.createAxis = function(whichAxis, max, color){
          whichAxis = whichAxis.toLowerCase();
          if(["x", "y", "z"].indexOf(whichAxis) < 0){
             console.log("illegal axis specified, should be x, y or z")
             return(None);
             }
         var lineGeo = new THREE.Geometry();
         var lineMat = new THREE.LineBasicMaterial({color: color, linewidth: 2});
         var start, end;
         switch(whichAxis){
            case "x":
               start = new THREE.Vector3(-1 * max, 0, 0);
               end = new THREE.Vector3(max, 0, 0);
               //lineVertices = [new THREE.Vector3(-1 * max, 0, 0), new THREE.Vector3(max, 0, 0)];
               break;
            case "y":
               start = new THREE.Vector3(0, -1 * max, 0)
               end = new THREE.Vector3(0, max, 0);
               //lineVertices = [new THREE.Vector3(0, -1 * max, 0), new THREE.Vector3(0, max, 0)];
               break;
            case "z":
               start = new THREE.Vector3(0, 0, -1 * max)
               end = new THREE.Vector3(0, 0, max);
               //lineVertices = [new THREE.Vector3(0, 0, -1 * max), new THREE.Vector3(0, 0, max)];
               break;
               } // switch on whichAxis
         lineGeo.vertices.push(start, end);
         var line = new THREE.Line(lineGeo, lineMat);
         line.type = THREE.Lines;
         console.log("---- returning axis");
         console.log(line);
         return(line);
         } // createaxis

      //----------------------------------------------------------------------------------------------------
      this.getName = function(){
         return name;
         }

      //----------------------------------------------------------------------------------------------------
      this.drawScatterPlot = function(){

         var material = new THREE.PointsMaterial({vertexColors: true, size: 0.5});
         var scene = new THREE.Scene();
         var camera = new THREE.PerspectiveCamera(45, 1, 1, 10000);  // view angle, apect, near & far clipping planes

         var renderer = new THREE.WebGLRenderer({antialias: true});
         var w = window.innerWidth * 0.8;
         var h = window.innerHeight * 0.8;
         renderer.setSize(w, h);

         var threeDiv = document.getElementById("threeDiv");
         //var canvasWidth = 500;
         //var canvasHeight = 500;
         threeDiv.appendChild(renderer.domElement);

         //document.body.appendChild(renderer.domElement);
         //renderer.setSize(canvasWidth, canvasHeight, updateCSSStyle);



         renderer.setClearColor(0xFFFFEE, 1.0);

         var camera = new THREE.PerspectiveCamera(45, w/h, 1, 10000);
         camera.position.z = 100;
         camera.position.x = 0;
         camera.position.y = 75;

         var scene = new THREE.Scene();

         var scatterPlot = new THREE.Object3D();
         scene.add(scatterPlot);

         scatterPlot.rotation.y = 0.5;
         debugger;
         var xAxis = this.createAxis("x", 20, "blue");
         console.log("---- axis from function")
         console.log(xAxis);
         scatterPlot.add(this.createAxis("x", 20, "blue"));
         scatterPlot.add(this.createAxis("y", 20, "red"));
         scatterPlot.add(this.createAxis("z", 20, "green"));

         var pointCount = data.length;
         pointCount = 100
         var pointGeometry = new THREE.Geometry();
         for (var i=0; i<pointCount; i++) {
            pointGeometry.vertices.push(new THREE.Vector3(data[i].pos/17105336, data[i].af, data[i].EC1));
            pointGeometry.colors.push(new THREE.Color("red"));
            } // for i

         var points = new THREE.Points(pointGeometry, material);
         scatterPlot.add(points);
         scene.add(scatterPlot);

         scene.fog = new THREE.FogExp2(0xFFFFFF, 0.0035);

         renderer.render(scene, camera);

         var paused = false;
         var last = new Date().getTime();
         var mousedown = false;
         var sx = 0, sy = 0;

         window.addEventListener('mousewheel', mouseWheelEvent);     // For Chrome
         window.addEventListener('DOMMouseScroll', mouseWheelEvent); // For Firefox
         var zoomFactor = 1.5;
         function mouseWheelEvent(e){
            //console.log(" --- mouseWheelEvent");
            var delta = e.wheelDelta ? e.wheelDelta : -e.detail;
            if(delta > 0){
              camera.fov *= (1/zoomFactor);
              camera.updateProjectionMatrix();
              //console.log("positive");
              }
            else{
              camera.fov *= zoomFactor;
              camera.updateProjectionMatrix();
              //console.log("negative");
              }
           } // mouseWheelEvent


         window.onmousedown = function (ev){
            mousedown = true; sx = ev.clientX; sy = ev.clientY;
            };
         window.onmouseup = function(){mousedown = false;};
         window.onmousemove = function(ev) {
            if (mousedown) {
              var dx = ev.clientX - sx;
              var dy = ev.clientY - sy;
              scatterPlot.rotation.y += dx*0.01;
              camera.position.y += dy;
              sx += dx;
              sy += dy;
              } // if
            } // on.mousemove

         function animate(t) {
           renderer.clear();
           camera.lookAt(scene.position);
           renderer.render(scene, camera);
           window.requestAnimationFrame(animate, renderer.domElement);
           };
         animate(new Date().getTime());
         } // drawScatterPlot


      }; // self()

   return self;
   });
//------------------------------------------------------------------------------------------------------------------------
