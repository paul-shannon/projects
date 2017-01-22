require.config({
    'shim' : {
        'bootstrap': {'deps' :['jquery']},
        'igv': {'deps' :['jquery', 'jquery-ui', 'bootstrap']}
    },
     'paths': {
        'jquery'    :   'http://code.jquery.com/jquery-1.12.4.min',
        'jquery-ui' :   'http://code.jquery.com/ui/1.12.1/jquery-ui.min',
        'bootstrap' :   'http://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min',
        'igv'       :   'http://igv.org/web/release/1.0.6/igv-1.0.6'
        }
});

require(['igv'], function (igv) {
    console.log("--- entering main in tabs/igv.js");
    var igvDiv;
    $(function(){
        console.log("enter igv.js docReady, igv?");
        console.log(igv)
        igvDiv = $("#igvDiv");
        options = {
            palette: ["#00A0B0", "#6A4A3C", "#CC333F", "#EB6841"],
            locus: "7:55,085,725-55,276,031",
            reference: {id: "hg19",
                fastaURL: "http://igv.broadinstitute.org/genomes/seq/1kg_v37/human_g1k_v37_decoy.fasta",
                cytobandURL: "http://igv.broadinstitute.org/genomes/seq/b37/b37_cytoband.txt"
            },
            trackDefaults: {
                bam: {coverageThreshold: 0.2,
                    coverageQualityWeight: true
                }
            },
            tracks: [
                {name: "Genes",
                    url: "http://igv.broadinstitute.org/annotations/hg19/genes/gencode.v18.collapsed.bed",
                    index: "http://igv.broadinstitute.org/annotations/hg19/genes/gencode.v18.collapsed.bed.idx",
                    displayMode: "EXPANDED"
                }
            ]
        }; // options


    newOptions = {locus: "5:88,621,548-88,999,827",
            reference: {id: "geneSymbols_hg38",
                fastaURL: "http://localhost/data/genomes/human_g1k_v37_decoy.fasta",
                cytobandURL: "http://localhost/data/annotations/b37_cytoband.txt"
                },
               tracks: [
                 {name: 'Gencode v24',
                  url: "http://localhost://data/hg38/gencode.v24.annotation.sorted.gtf.gz",
                  indexURL: "http://localhost://data/hg38/gencode.v24.annotation.sorted.gtf.gz.tbi",
                  format: 'gtf',
                  visibilityWindow: 1000000,
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
              }; // newOptions

        $("#tabs").tabs({
           create: function(event, ui){console.log(tabs.create)}
           });
        console.log("about to createBrowser");
        setTimeout(function(){
           $("#igvDiv").text(""); // remove any message
           browser = igv.createBrowser(igvDiv, newOptions);
           }, 5000);
    }); // onready funcetion
});
