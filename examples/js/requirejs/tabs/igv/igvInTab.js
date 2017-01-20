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
        console.log("about to createBrowser");
        browser = igv.createBrowser(igvDiv, options);
        $("#tabs").tabs();
    }); // onready funcetion
});
