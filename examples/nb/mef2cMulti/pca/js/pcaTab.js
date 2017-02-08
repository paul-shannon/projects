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

      demoData: function(){
        var data3 = [{"gene":"ADNP","x":-146.0568,"y":-0.7765,"z":1.345},
                     {"gene":"ADNP2","x":-111.9405,"y":0.7206,"z":1.9047},
                     {"gene":"ALX1","x":51.0562,"y":-9.3092,"z":-15.5825},
                     {"gene":"ALX3","x":-38.909,"y":-2.9967,"z":1.2376},
                     {"gene":"ALX4","x":-17.7929,"y":-2.9019,"z":-6.0279},
                     {"gene":"ARGFX","x":87.2175,"y":7.2355,"z":-7.2452},
                     {"gene":"ARX","x":-91.302,"y":5.8996,"z":0.9547},
                     {"gene":"CRX","x":24.0127,"y":-1.8842,"z":1.1204},
                     {"gene":"DPRX","x":96.4716,"y":-11.5378,"z":13.6378},
                     {"gene":"DRGX","x":-30.3606,"y":20.0352,"z":0.1661},
                     {"gene":"DUXA","x":124.1735,"y":1.6056,"z":1.2608},
                     {"gene":"ELF3","x":6.4602,"y":2.3951,"z":2.9274},
                     {"gene":"ESX1","x":125.4266,"y":2.1301,"z":2.1979},
                     {"gene":"GSC","x":101.5726,"y":-6.5466,"z":-5.9331},
                     {"gene":"GSC2","x":113.1012,"y":4.1633,"z":4.064},
                     {"gene":"HESX1","x":-21.7646,"y":-0.5798,"z":4.4957},
                     {"gene":"HOMEZ","x":-90.9856,"y":-2.7474,"z":1.2747},
                     {"gene":"HOPX","x":-155.0937,"y":4.4173,"z":-0.9517},
                     {"gene":"ISX","x":121.934,"y":2.3002,"z":0.6731},
                     {"gene":"LEUTX","x":125.4103,"y":1.7299,"z":2.0273},
                     {"gene":"MEF2C","x":-168.1081,"y":10.322,"z":2.2409},
                     {"gene":"MIXL1","x":29.8232,"y":5.892,"z":5.236},
                     {"gene":"NOBOX","x":114.7024,"y":4.3831,"z":2.4121},
                     {"gene":"OTP","x":73.4485,"y":22.8675,"z":1.6014},
                     {"gene":"OTX1","x":-61.1505,"y":-1.0486,"z":-1.7832},
                     {"gene":"OTX2","x":91.1536,"y":-16.412,"z":5.2518},
                     {"gene":"PHOX2A","x":85.9395,"y":0.0448,"z":-10.3375},
                     {"gene":"PHOX2B","x":123.2999,"y":1.5495,"z":4.2616},
                     {"gene":"PITX1","x":86.3081,"y":-14.9184,"z":-4.9912},
                     {"gene":"PITX2","x":113.9095,"y":3.6351,"z":-1.4579},
                     {"gene":"PITX3","x":98.6208,"y":3.3063,"z":4.4485},
                     {"gene":"PROP1","x":54.8345,"y":11.5046,"z":-22.5947},
                     {"gene":"PRRX1","x":-97.6001,"y":-7.997,"z":-0.1716},
                     {"gene":"PRRX2","x":-2.1381,"y":-7.3584,"z":-5.464},
                     {"gene":"RAX","x":98.7371,"y":-21.1732,"z":20.4459},
                     {"gene":"RAX2","x":32.2993,"y":-5.3922,"z":-13.5179},
                     {"gene":"RHOXF1","x":-17.3206,"y":2.2535,"z":-0.6599},
                     {"gene":"RHOXF2","x":98.8198,"y":-1.538,"z":0.2752},
                     {"gene":"RHOXF2B","x":117.5179,"y":6.9199,"z":4.6329},
                     {"gene":"SEBOX","x":87.627,"y":3.701,"z":-6.6413},
                     {"gene":"SHOX","x":79.1686,"y":-6.9527,"z":-11.0102},
                     {"gene":"SHOX2","x":60.181,"y":7.1496,"z":16.6654},
                     {"gene":"TPRX1","x":84.3702,"y":-3.7428,"z":-17.4296},
                     {"gene":"TSHZ1","x":-129.1469,"y":-0.1712,"z":-0.473},
                     {"gene":"TSHZ2","x":-101.2699,"y":7.1558,"z":1.7648},
                     {"gene":"TSHZ3","x":-105.0179,"y":4.4191,"z":0.3811},
                     {"gene":"UNCX","x":111.1621,"y":-6.2214,"z":7.1391},
                     {"gene":"VSX1","x":-64.5455,"y":-4.3236,"z":1.3823},
                     {"gene":"VSX2","x":36.9045,"y":17.9651,"z":13.514},
                     {"gene":"ZBTB16","x":-125.9315,"y":-0.172,"z":0.1997},
                     {"gene":"ZEB1","x":-144.9223,"y":-2.2388,"z":0.2275},
                     {"gene":"ZEB2","x":-166.8426,"y":-5.2802,"z":3.2249},
                     {"gene":"ZFHX2","x":-113.4972,"y":-0.5561,"z":-3.1312},
                     {"gene":"ZFHX3","x":-115.247,"y":-3.7799,"z":-1.7704},
                     {"gene":"ZFHX4","x":-120.3524,"y":-4.7425,"z":0.162},
                     {"gene":"ZHX1","x":-140.2198,"y":-3.0202,"z":0.5338},
                     {"gene":"ZHX2","x":-124.4253,"y":-5.8642,"z":1.7423},
                     {"gene":"ZHX3","x":-153.7224,"y":-3.5177,"z":0.1432}];
          return(data3);
        },
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



           //window.onmousedown = function (ev){
           $("#pcaDiv").mousedown(function(ev){
               console.log(" --- pca mousedown");
               console.log(" --- ev");
               console.log(ev);
               mousedown = true; sx = ev.clientX; sy = ev.clientY;
               });
            /*******************
            console.log(" --- ev");
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
            *******************/

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
