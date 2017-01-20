require.config({
    paths: {
      'leaflet': 'https://unpkg.com/leaflet@1.0.2/dist/leaflet',
      'jquery':   'http://code.jquery.com/jquery-1.12.4.min',
      'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min'
       },
    shim: {
       leaflet: {deps: ['jquery', 'jquery-ui'], exports: 'L'},
        }
    });

require(['leaflet'], function(L) {

  console.log("starting leaflet main");
  $(function(){
     console.log("starting leaflet doc ready");
     $("#tabs").tabs();
     seattle = {lat: 47.59,    long: -122.335167, zoom: 12};
     denver  = {lat: 39.74739, long: -105,        zoom: 13};
     loc = seattle;

     var map = L.map('mapDiv').setView([loc.lat, loc.long], loc.zoom);
     window.map = map;
     var mapURI = 'https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpandmbXliNDBjZWd2M2x6bDk3c2ZtOTkifQ._QA7i5Mpkd_m30IGElHziw';

     L.tileLayer(mapURI, {
             maxZoom: 18,
             attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
                           '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                           'Imagery © <a href="http://mapbox.com">Mapbox</a>',
             id: 'mapbox.light'
         }).addTo(map);
       });
     }); // require
