require.config({
   paths: {'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
           'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
            'three':   'https://cdnjs.cloudflare.com/ajax/libs/three.js/r83/three'},
   shim:  {'three':
      {'exports': 'THREE'}}
   });

//------------------------------------------------------------------------------------------------------------------------
define(['jquery', 'jquery-ui', 'three'], function ($, ui, THREE) {

    var app3d = {
        name: "app3d",
        renderer: null,
        targetDivName: null,
        targetDiv: null,
        scene: null,
        camera: null,
        material: null,
        scatterPlot: null,
        scatterPlotWidget: null,

        init:  function(targetDivName){

         createAxis = function (whichAxis, max, color){
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
                   break;
                case "y":
                   start = new THREE.Vector3(0, -1 * max, 0)
                   end = new THREE.Vector3(0, max, 0);
                   break;
                case "z":
                   start = new THREE.Vector3(0, 0, -1 * max)
                   end = new THREE.Vector3(0, 0, max);
                   break;
                   } // switch on whichAxis
             lineGeo.vertices.push(start, end);
             var line = new THREE.Line(lineGeo, lineMat);
             line.type = THREE.Lines;
             return(line);
             }; // createAxis

           console.log("initializing scatter3d");
           app3d.targetDivName = targetDivName;
           app3d.material = new THREE.PointsMaterial({vertexColors: true, size: 0.5});
           app3d.scene = new THREE.Scene();
           app3d.camera = new THREE.PerspectiveCamera(45, 1, 1, 10000);  // view angle, apect, near & far clipping planes
           app3d.renderer = new THREE.WebGLRenderer({antialias: true});
           var w = window.innerWidth * 0.8;
           var h = window.innerHeight * 0.8;
           app3d.renderer.setSize(w, h);
           app3d.targetDiv = document.getElementById(app3d.targetDivName);
           console.log("app3d");
           console.log(app3d)
           app3d.targetDiv.appendChild(app3d.renderer.domElement);
           app3d.renderer.setClearColor(0xFFFFEE, 1.0);

           app3d.camera = new THREE.PerspectiveCamera(45, w/h, 1, 10000);
           app3d.camera.position.z = 100;
           app3d.camera.position.x = 0;
           app3d.camera.position.y = 75;

           app3d.scatterPlot = new THREE.Object3D();
           app3d.scene.add(app3d.scatterPlot);

           app3d.scatterPlot.rotation.y = 0.5;
           app3d.scatterPlot.add(createAxis("x", 20, "blue"));
           app3d.scatterPlot.add(createAxis("y", 20, "red"));
           app3d.scatterPlot.add(createAxis("z", 20, "green"));
           window.app3d = app3d;
           return(app3d);
           }, //


      //----------------------------------------------------------------------------------------------------
       getName: function(){
          return name;
          },

      //----------------------------------------------------------------------------------------------------
       drawScatterPlot: function(data){
         var pointCount = data.length;
         var pointGeometry = new THREE.Geometry();
         for (var i=0; i<pointCount; i++) {
            var point = data[i];
            pointGeometry.vertices.push(new THREE.Vector3(point.pos/17105336, point.af, point.EC1));
            pointGeometry.colors.push(new THREE.Color("red"));
            } // for i

         var points = new THREE.Points(pointGeometry, app3d.material);
         app3d.scatterPlot.add(points);
         app3d.scene.fog = new THREE.FogExp2(0xFFFFFF, 0.0035);
         app3d.renderer.render(app3d.scene, app3d.camera);

         var paused = false;
         var last = new Date().getTime();
         var mousedown = false;
         var sx = 0, sy = 0;
         var zoomFactor = 1.5;

         function mouseWheelEvent(e){
            console.log(" --- mouseWheelEvent");
            var delta = e.wheelDelta ? e.wheelDelta : -e.detail;
            if(delta > 0){
               app3d.camera.fov *= (1/zoomFactor);
               app3d.camera.updateProjectionMatrix();
               }
            else{
               app3d.camera.fov *= zoomFactor;
               app3d.camera.updateProjectionMatrix();
               }
            } // mouseWheelEvent


         window.onmousedown = function (ev){
            mousedown = true; sx = ev.clientX; sy = ev.clientY;
            };
         window.onmouseup = function(){mousedown = false;};
         window.onmousemove = function(ev){
            if(mousedown){
               var dx = ev.clientX - sx;
               var dy = ev.clientY - sy;
               app3d.scatterPlot.rotation.y += dx*0.01;
               app3d.camera.position.y += dy;
               sx += dx;
               sy += dy;
               } // if
            }; // on.mousemove
         window.addEventListener('mousewheel', mouseWheelEvent);     // For Chrome
         window.addEventListener('DOMMouseScroll', mouseWheelEvent); // For Firefox
         }, // draw

        animate: function(){
           //console.log("animate")
           app3d.renderer.clear();
           app3d.camera.lookAt(app3d.scene.position);
           app3d.renderer.render(app3d.scene, app3d.camera);
           window.requestAnimationFrame(app3d.animate);
           }
         }; // app3d
      return app3d;
   });
//------------------------------------------------------------------------------------------------------------------------
