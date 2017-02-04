require.config({
   paths: {'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
           'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
            'three':   'https://cdnjs.cloudflare.com/ajax/libs/three.js/r83/three'},
   shim:  {'three':
      {'exports': 'THREE'}}
   });

//------------------------------------------------------------------------------------------------------------------------
define(['jquery', 'jquery-ui', 'three'], function ($, ui, THREE) {

   var self = function(){

      var name = 'scatter3d';
      var renderer = null;
      var targetDivName = null;
      var targetDiv = null;
      var scene = null;
      var camera = null;
      var material = null;
      var scatterPlot = null;
      var scatterPlotWidget = null

      //----------------------------------------------------------------------------------------------------
      this.init = function(targetDivName, data){

         console.log("initializing scatter3d");
         this.targetDivName = targetDivName;
         this.data = data;
         this.material = new THREE.PointsMaterial({vertexColors: true, size: 0.5});
         this.scene = new THREE.Scene();
         this.camera = new THREE.PerspectiveCamera(45, 1, 1, 10000);  // view angle, apect, near & far clipping planes

         this.renderer = new THREE.WebGLRenderer({antialias: true});
         var w = window.innerWidth * 0.8;
         var h = window.innerHeight * 0.8;
         this.renderer.setSize(w, h);
         this.targetDiv = document.getElementById(this.targetDivName);
         this.targetDiv.appendChild(this.renderer.domElement);
         this.renderer.setClearColor(0xFFFFEE, 1.0);

         this.camera = new THREE.PerspectiveCamera(45, w/h, 1, 10000);
         this.camera.position.z = 100;
         this.camera.position.x = 0;
         this.camera.position.y = 75;

         this.scatterPlot = new THREE.Object3D();
         this.scene.add(this.scatterPlot);

         this.scatterPlot.rotation.y = 0.5;
         this.scatterPlot.add(this.createAxis("x", 20, "blue"));
         this.scatterPlot.add(this.createAxis("y", 20, "red"));
         this.scatterPlot.add(this.createAxis("z", 20, "green"));
         window.scatterPlotWidget = this;
         return(this);
         }

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
         return(line);
         } // createaxis

      //----------------------------------------------------------------------------------------------------
      this.getName = function(){
         return name;
         }

      //----------------------------------------------------------------------------------------------------
      this.drawScatterPlot = function(){

         /**************
        var material = new THREE.PointsMaterial({vertexColors: true, size: 0.5});
         scene = new THREE.Scene();
         camera = new THREE.PerspectiveCamera(45, 1, 1, 10000);  // view angle, apect, near & far clipping planes

         var renderer = new THREE.WebGLRenderer({antialias: true});
         var w = window.innerWidth * 0.8;
         var h = window.innerHeight * 0.8;
         renderer.setSize(w, h);

         var threeDiv = document.getElementById(this.targetDiv);
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
         scatterPlot.add(this.createAxis("x", 20, "blue"));
         scatterPlot.add(this.createAxis("y", 20, "red"));
         scatterPlot.add(this.createAxis("z", 20, "green"));
          ***********/

         var pointCount = this.data.length;
         //pointCount = 100
         var pointGeometry = new THREE.Geometry();
         for (var i=0; i<pointCount; i++) {
            var point = data[i];
            pointGeometry.vertices.push(new THREE.Vector3(point.pos/17105336, point.af, point.EC1));
            pointGeometry.colors.push(new THREE.Color("red"));
            } // for i

         var points = new THREE.Points(pointGeometry, this.material);
         this.scatterPlot.add(points);
         //this.scene.add(this.scatterPlot);

         this.scene.fog = new THREE.FogExp2(0xFFFFFF, 0.0035);

         this.renderer.render(this.scene, this.camera);

         var paused = false;
         var last = new Date().getTime();
         var mousedown = false;
         var sx = 0, sy = 0;

         window.addEventListener('mousewheel', mouseWheelEvent);     // For Chrome
         window.addEventListener('DOMMouseScroll', mouseWheelEvent); // For Firefox
         var zoomFactor = 1.5;
         var scatter3dObject = this;
         function mouseWheelEvent(e){
            //console.log(" --- mouseWheelEvent");
            var delta = e.wheelDelta ? e.wheelDelta : -e.detail;
            if(delta > 0){
              scatter3dObject.camera.fov *= (1/zoomFactor);
              scatter3dObject.camera.updateProjectionMatrix();
              //console.log("positive");
              }
            else{
              scatter3dObject.camera.fov *= zoomFactor;
              scatter3dObject.camera.updateProjectionMatrix();
              //console.log("negative");
              }
           } // mouseWheelEvent


         window.onmousedown = function (ev){
            mousedown = true; sx = ev.clientX; sy = ev.clientY;
            };
         window.onmouseup = function(){mousedown = false;};
         that = this;
         window.onmousemove = function(ev) {
            if (mousedown) {
              var dx = ev.clientX - sx;
              var dy = ev.clientY - sy;
              that.scatterPlot.rotation.y += dx*0.01;
              that.camera.position.y += dy;
              sx += dx;
              sy += dy;
              } // if
            } // on.mousemove

         this.animate = function() {
           console.log("----- entering animate")
           console.log(this);
           window.scatterPlotWidget.renderer.clear();
           console.log("--- 2");
           window.scatterPlotWidget.camera.lookAt(window.scatterPlotWidget.scene.position);
           console.log("--- 3");
           console.log("---- window.scatterPlotWidget.scene: ")
           console.log(window.scatterPlotWidget.scene)
           console.log("---- window.scatterPlotWidget.camera ")
           console.log(window.scatterPlotWidget.camera)
           window.scatterPlotWidget.renderer.render(window.scatterPlotWidget.scene, window.scatterPlotWidget.camera);
           console.log("--- 4");
           //window.requestAnimationFrame(boundAnimate, window.scatterPlotWidget.renderer.domElement);
           console.log("--- 5");
           };
         //boundAnimate = _.bind(this.animate, this)'
         //boundAnimate()
         //window.scatterPlotWidget.animate();
         } // drawScatterPlot


      }; // self()

   return self;
   });
//------------------------------------------------------------------------------------------------------------------------
