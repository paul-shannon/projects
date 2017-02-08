require.config({
   paths: {'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
           'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
           'igv'       :   'http://igv.org/web/release/1.0.6/igv-1.0.6'},
    shim: {'igv'       :   {'deps'   : ['jquery', 'jquery-ui']}}
});

//------------------------------------------------------------------------------------------------------------------------
define(['jquery', 'jquery-ui', 'igv'], function ($, ui, igv) {

   var igvTab = {

       name: "igvTab",
       igvBrowser: null,
       config: null,
       targetDivName: null,
       targetDiv: null,

       init:  function(targetDivName){
           igvTab.config = {locus: "7:101,165,052-101,166,122", // 5:88,621,548-88,999,827",
              reference: {id: "geneSymbols_hg38",
                          fastaURL: "http://localhost/data/genomes/human_g1k_v37_decoy.fasta",
                          cytobandURL: "http://localhost/data/annotations/b37_cytoband.txt"
                          },
              tracks: [
                  {name: 'Gencode v24',
                   url: "http://localhost://data/hg38/gencode.v24.annotation.sorted.gtf.gz",
                   indexURL: "http://localhost://data/hg38/gencode.v24.annotation.sorted.gtf.gz.tbi",
                   format: 'gtf',
                   visibilityWindow: 2000000,
                   displayMode: 'EXPANDED'
                   },
                  {name: 'geneSymbols_hg38',
                   url: 'http://localhost/data/hg38/geneSymbolSearch.bed',
                   indexed: false,
                   searchable: true,
                   //visibilityWindow: 5000000,
                   displayMode: 'COLLAPSED',
                   color: "#448844"
                   },
                  {name: "igap gwas",
                   url: 'http://localhost/data/hg38/variants/igap.bed',
                   indexed: false,
                   searchable: true,
                   //visibilityWindow: 5000000,
                   displayMode: 'EXPANDED',
                   color: "#884444"
                   }
                   ]
              }, // config
           targetDivId = '#' + targetDivName;
           igvTab.targetDiv = $(targetDivId);
       }, // init
       display: function(){
         igvTab.igvBrowser = igv.createBrowser(igvTab.targetDiv, igvTab.config)
         }
     }; // igvTab
   return igvTab;
});
//------------------------------------------------------------------------------------------------------------------------
