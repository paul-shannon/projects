require.config({
   paths: {'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
           'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
            'three':   'https://cdnjs.cloudflare.com/ajax/libs/three.js/r83/three'},
   shim:  {'three':
      {'exports': 'THREE'}}
   });

//------------------------------------------------------------------------------------------------------------------------
define(['jquery', 'jquery-ui', 'three'], function ($, ui, THREE) {

    var pcaTab = {
        name: "pcaTab",
        renderer: null,
        targetDivName: null,
        targetDiv: null,
        scene: null,
        camera: null,
        pointsMaterial: null,
        scatterPlot: null,
        scatterPlotWidget: null,
        points: [],

        init:  function(targetDivName){

           createAxis = function (whichAxis, max, color){
              whichAxis = whichAxis.toLowerCase();
              if(["x", "y", "z"].indexOf(whichAxis) < 0){
                 console.log("illegal axis specified, should be x, y or z")
                 return(None);
                 }
               var lineGeo = new THREE.Geometry({pointSize:3});
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
           pcaTab.targetDivName = targetDivName;
           pcaTab.pointsMaterial = new THREE.PointsMaterial({vertexColors: true, size: 10});
           pcaTab.scene = new THREE.Scene();
           pcaTab.camera = new THREE.PerspectiveCamera(45, 1, 1, 10000);  // view angle, apect, near & far clipping planes
           pcaTab.renderer = new THREE.WebGLRenderer({antialias: true});
           var w = window.innerWidth * 0.8;
           var h = window.innerHeight * 0.8;
           pcaTab.renderer.setSize(w, h);
           pcaTab.targetDiv = document.getElementById(pcaTab.targetDivName);
           console.log("pcaTab");
           console.log(pcaTab)
           pcaTab.targetDiv.appendChild(pcaTab.renderer.domElement);
           pcaTab.renderer.setClearColor(0x000000, 1.0);

           pcaTab.camera = new THREE.PerspectiveCamera(45, w/h, 1, 10000);
           pcaTab.camera.position.z = 1000;
           pcaTab.camera.position.x = 0;
           pcaTab.camera.position.y = 75;

           pcaTab.scatterPlot = new THREE.Object3D();
           pcaTab.scene.add(pcaTab.scatterPlot);

           pcaTab.scatterPlot.rotation.y = 0.5;
           pcaTab.scatterPlot.add(createAxis("x", 5, "blue"));
           pcaTab.scatterPlot.add(createAxis("y", 5, "red"));
           pcaTab.scatterPlot.add(createAxis("z", 5, "green"));
           window.pcaTab = pcaTab;
           return(pcaTab);
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
            //pointGeometry.vertices.push(new THREE.Vector3(point.pos/17105336, point.af, point.EC1));
            pointGeometry.vertices.push(new THREE.Vector3(point.x, point.y, point.z));
            color = new THREE.Color();
            color.setHSL(Math.random(), 1.0, 0.5);
            pointGeometry.colors.push(color);
            //pointGeometry.colors.push(new THREE.Color("white"));
            } // for i

         pcaTab.points = new THREE.Points(pointGeometry, pcaTab.pointsMaterial);
         pcaTab.scatterPlot.add(pcaTab.points);
         pcaTab.renderer.render(pcaTab.scene, pcaTab.camera);

         var paused = false;
         var last = new Date().getTime();
         var mousedown = false;
         var sx = 0, sy = 0;
         var zoomFactor = 1.5;

        function drawBoundingBox(){
           function v(x,y,z){ return new THREE.Vector3(x,y,z); }
           var lineGeo = new THREE.Geometry();
           maxValue = 180;
           lineGeo.vertices.push(

               v(-maxValue,  maxValue, -maxValue), v( maxValue,  maxValue, -maxValue),
               v( maxValue, -maxValue, -maxValue), v( -maxValue, -maxValue, -maxValue),
               v(-maxValue,  maxValue, -maxValue), v(-maxValue,  maxValue, maxValue),

               v( maxValue,  maxValue, maxValue),
               v( maxValue, -maxValue, maxValue),
               v( -maxValue, -maxValue, maxValue),
               v(-maxValue,  maxValue, maxValue),

               v( -maxValue, -maxValue, maxValue), v( -maxValue, -maxValue, -maxValue),
               v( maxValue, -maxValue, -maxValue), v( maxValue, -maxValue, maxValue),
               v( maxValue, maxValue, maxValue),   v( maxValue, maxValue, -maxValue),

               //v(-maxValue, -maxValue, maxValue),
               //v(-maxValue, -maxValue, -maxValue),
               //v(-maxValue, maxValue, -maxValue),
               //v(-maxValue, maxValue, maxValue),

             //v(-maxValue, -maxValue, -maxValue), v(maxValue, -maxValue, -maxValue),
             //v(-maxValue, maxValue, maxValue), v(maxValue, maxValue, maxValue),
             //v(-maxValue, -maxValue, maxValue), v(maxValue, -maxValue, maxValue),

             //v(maxValue, -maxValue, -maxValue), v(maxValue, maxValue, -maxValue),
             //v(-maxValue, -maxValue, -maxValue), v(-maxValue, maxValue, -maxValue),
             //v(maxValue, -maxValue, maxValue), v(maxValue, maxValue, maxValue),
             //v(-maxValue, -maxValue, maxValue), v(-maxValue, maxValue, maxValue),

             //v(maxValue, maxValue, -maxValue), v(maxValue, maxValue, maxValue),
             //v(maxValue, -maxValue, -maxValue), v(maxValue, -maxValue, maxValue),
             //v(-maxValue, maxValue, -maxValue), v(-maxValue, maxValue, maxValue),
             //v(-maxValue, -maxValue, -maxValue), v(-maxValue, -maxValue, maxValue)
           );


            /**************
            v(-maxValue, maxValue, -maxValue), v(maxValue, maxValue, -maxValue),
              v(-maxValue, -maxValue, -maxValue), v(maxValue, -maxValue, -maxValue),
             v(-maxValue, maxValue, maxValue), v(maxValue, maxValue, maxValue),
             v(-maxValue, -maxValue, maxValue), v(maxValue, -maxValue, maxValue),

             v(maxValue, -maxValue, -maxValue), v(maxValue, maxValue, -maxValue),
             v(-maxValue, -maxValue, -maxValue), v(-maxValue, maxValue, -maxValue),
             v(maxValue, -maxValue, maxValue), v(maxValue, maxValue, maxValue),
             v(-maxValue, -maxValue, maxValue), v(-maxValue, maxValue, maxValue),

             v(maxValue, maxValue, -maxValue), v(maxValue, maxValue, maxValue),
             v(maxValue, -maxValue, -maxValue), v(maxValue, -maxValue, maxValue),
             v(-maxValue, maxValue, -maxValue), v(-maxValue, maxValue, maxValue),
             v(-maxValue, -maxValue, -maxValue), v(-maxValue, -maxValue, maxValue)
           );
             ************/
           var lineMat = new THREE.LineBasicMaterial({color: 0xFFFFFF, linewidth: 1});
           var line = new THREE.Line(lineGeo, lineMat);
           line.type = THREE.Lines;
           return(line)
           } // drawBoundingBox

         pcaTab.scatterPlot.add(drawBoundingBox());

         function mouseWheelEvent(event){
            if(document.getElementById("pcaDiv").contains(event.target)){
               console.log(" --- mouseWheelEvent");
               console.log(event.target);
               var delta = event.wheelDelta ? event.wheelDelta : -event.detail;
               if(delta > 0){
                  pcaTab.camera.fov *= (1/zoomFactor);
                  pcaTab.camera.updateProjectionMatrix();
                  }
               else{
                  pcaTab.camera.fov *= zoomFactor;
                  pcaTab.camera.updateProjectionMatrix();
                  }
               event.stopPropagation();
               event.preventDefault();
               console.log(" *** just stopped propagation")
               } // if even in pcaDiv
            } // mouseWheelEvent

         handleResize = function() {
           console.log("resize");
           var newWidth = $("#pcaDiv").width();
           var newHeight = $("#pcaDiv").height();
           pcaTab.renderer.setSize(newWidth, newHeight);
           }; // resize handler

         $(window).resize(handleResize);

         var raycaster = new THREE.Raycaster();
         var mouse = new THREE.Vector2();

          //projector.unprojectVector( mouseVector, camera );
          //var raycaster = new THREE.Raycaster( camera.position, mouseVector.subSelf( camera.position ).normalize() );



         window.onmousedown = function (ev){
            console.log(" --- mousedown");
            mousedown = true; sx = ev.clientX; sy = ev.clientY;
            var raycaster = new THREE.Raycaster();
            var mouse = new THREE.Vector2();
            mouse.x = ( ev.clientX / window.innerWidth ) * 2 - 1;
            mouse.y = - ( ev.clientY / window.innerHeight ) * 2 + 1;
            console.log("mouse: " + mouse.x + ", " + mouse.y);
            console.log("children: ");
             console.log(pcaTab.scene.children);
            raycaster.setFromCamera(mouse, pcaTab.camera );
            var intersects = raycaster.intersectObjects(pcaTab.scene.children);
            //console.log(pcaTab.points)
            // console.log(pcaTab.points[0]);
            //var intersects = raycaster.intersectObjects(pcaTab.points);
            console.log(intersects.length);
            } // onmousedown
            //var vector = new THREE.Vector3((ev.clientX / window.innerWidth) * 2 - 1,
            //                                -(ev.clientY / window.innerHeight) * 2 + 1, 0.5);
            //projector.unprojectVector(vector, pcaTab.camera);
            //var raycaster = new THREE.Raycaster(pcaTab.camera.position, vector.sub(pcaTab.camera.position).normalize());
            //var intersects = raycaster.intersectObjects(pcaTab.points);
            //};

            //var projector = new THREE.Projector();
            //projector.unprojectVector(mouseVector, pcaTab.camera);
            //var raycaster = new THREE.Raycaster(pcaTab.camera.position, mouseVector.sub(pcaTab.camera.position).normalize());
            //var intersects = raycaster.intersectObjects(pcaTab.scene.children);
            // console.log(pcaTab.scene.children.length);
            //raycaster.setFromCamera(mouse, pcaTab.camera);
            //var intersects = raycaster.intersectObjects(pcaTab.scene.children);
            //console.log("intersecting objects: " + intersects.length);
            //for(var i = 0; i < intersects.length; i++){
            //  intersects[i].object.material.color.set(0xff0000);
            //  }
            //}; // onmousedown


         window.onmouseup = function(){mousedown = false;};
         window.onmousemove = function(event){
            if(document.getElementById("pcaDiv").contains(event.target)){
               if(mousedown){
                  var dx = event.clientX - sx;
                  var dy = event.clientY - sy;
                  pcaTab.scatterPlot.rotation.y += dx*0.01;
                  pcaTab.camera.position.y += dy;
                  sx += dx;
                  sy += dy;
                  } // if mousedown
              event.stopPropagation();
              event.preventDefault();
              } // if in pcaDiv
            }; // on.mousemove
         window.addEventListener('mousewheel', mouseWheelEvent);     // For Chrome
         window.addEventListener('DOMMouseScroll', mouseWheelEvent); // For Firefox
         handleResize();
         }, // draw

        resize: function(){
           handleResize()
           },

        animate: function(){
           //console.log("animate")
           pcaTab.renderer.clear();
           pcaTab.camera.lookAt(pcaTab.scene.position);
           pcaTab.renderer.render(pcaTab.scene, pcaTab.camera);
           window.requestAnimationFrame(pcaTab.animate);
           }
         }; // pcaTab
      return pcaTab;
   });
//------------------------------------------------------------------------------------------------------------------------
