var sprintKnockedOutEdges = [];
var tMobileKnockedOutEdges = [];
var attKnockedOutEdges = [];
var nextelKnockedOutEdges = [];
var verizonKnockedOutEdges = [];
var cellularOneKnockedOutEdges = [];
var usCellularOneKnockedOutEdges = [];
var selectedNodesKnockedOutEdges = [];

var withEmailKnockedOutEdges = [];
var withRoamingKnockedOutEdges = [];
var withCameraKnockedOutEdges = [];

var withoutEmailKnockedOutEdges = [];
var withoutRoamingKnockedOutEdges = [];
var withoutCameraKnockedOutEdges = [];

function foo(){
    var x = 99;
    console.log(x);
    };

function resetKnockoutMenu(){
        console.log("resetKnockoutMenu");
        $("#knockoutByCarrierMenuItems").hide();
        $("#knockoutByPropertiesMenuItems").hide();
        $("#knockoutWithPropertyMenuItems").hide();
        $("#knockoutByCarrierMenuItems").hide();
        $("#knockoutMenuItems").hide();
};

function resetReactivateMenu (){
        console.log("resetReactivateMenu");
        $("#reactivateByCarrierMenuItems").hide();
        $("#reactivateByPropertiesMenuItems").hide();
        $("#reactivateWithPropertyMenuItems").hide();
        $("#reactivateByCarrierMenuItems").hide();
        $("#reactivateMenuItems").hide();
};

module.exports = {

    init: function(){

     $("#knockoutMainMenuButton").on("click", function(e){
        console.log("main menu button: knockout");
        $("#knockoutMenuItems").toggle();
          // whether showing or hiding the first level menu
          // we always want the submenus hidden
        $("#knockoutByPropertiesMenuItems").hide();
        $("#knockoutByCarrierMenuItems").hide();
          // if another menu is up, hide it
        $("#reactivateMenuItems").hide()
        });

     $("#knockoutWithoutPropertyMenuHead").on("click", function(e){
        console.log("  phones without");
        $(this).next('ul').toggle();
        $("#knockoutWithPropertyMenuItems").hide();
        });

     $("#knockoutWithPropertyMenuHead").on("click", function(e){
        console.log("  phones with");
        $(this).next('ul').toggle();
        $("#knockoutWithoutPropertyMenuItems").hide();
        });

     $('#knockoutSelectedPhonesMenuItem').on("click", function(e){
        console.log("knockoutSelectedPhones");
        var selectedNodes = cy.nodes(":selected")
        selectedNodesKnockedOutEdges = cy.remove(selectedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     $("#knockoutByPropertiesMenuHead").on("click", function(e){
        console.log("knockoutByPropertiesMenuHead click");
          // toggle the "Phones with, Phones without submenu
        $('#knockoutByPropertiesMenuItems').toggle()
          // make sure the "By Carrier" menu is hidden
        $("#knockoutByCarrierMenuItems").hide()
          // make sure the sub-sub menus are both hidden
        $("#knockoutWithPropertyMenuHead").next("ul").hide()
        $("#knockoutWithoutPropertyMenuHead").next("ul").hide()
        });

     $('#knockoutByCarrierMenuHead').on("click", function(e){
        console.log("knockoutByCarrierMenuHead click");
        $("#knockoutByCarrierMenuItems").toggle()
        $('#knockoutByPropertiesMenuItems').hide()
        });

     $("#knockoutSprintPhonesMenuItem").on("click", function(e){
        console.log("knockout sprint phones");
        var carrierNodes = cy.nodes("[carrier='Sprint']");
        sprintKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
        resetKnockoutMenu();
        });


     $("#reactivateSprintPhonesMenuItem").on("click", function(e){
         console.log("reactivate sprint phones");
         if(sprintKnockedOutEdges.length > 0){
            cy.add(sprintKnockedOutEdges)
            sprintKnockedOutEdges = [];
            }
        resetReactivateMenu();
        });


     $("#knockoutTMobilePhonesMenuItem").on("click", function(e){
        console.log("knockout t-mobile phones");
        var carrierNodes = cy.nodes("[carrier='T-Mobile']");
        tMobileKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
        resetKnockoutMenu();
        });

      $("#knockoutATTPhonesMenuItem").on("click", function(e){
         console.log("knockout ATT phones");
         var carrierNodes = cy.nodes("[carrier='ATT']");
         attKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
         resetKnockoutMenu();
         });

      $("#knockoutNextelPhonesMenuItem").on("click", function(e){
         console.log("knockout nextel phones");
         var carrierNodes = cy.nodes("[carrier='Nextel']");
         nextelKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
         resetKnockoutMenu();
         });

      $("#knockoutVerizonPhonesMenuItem").on("click", function(e){
         console.log("knockout Verizon phones");
         var carrierNodes = cy.nodes("[carrier='Verizon Wireless']");
         verizonKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
         resetKnockoutMenu();
         });

      $("#knockoutCellularOnePhonesMenuItem").on("click", function(e){
         console.log("knockout cellular one phones");
         var carrierNodes = cy.nodes("[carrier='CellularOne']");
         cellularOneKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
         resetKnockoutMenu();
         });

      $("#knockoutUSCellularPhonesMenuItem").on("click", function(e){
         console.log("knockout us cellular phones");
         var carrierNodes = cy.nodes("[carrier='US Cellular']");
         usCellularOneKnockedOutEdges = cy.remove(carrierNodes.connectedEdges())
         resetKnockoutMenu();
         });

      $("#reactivateNextelPhonesMenuItem").on("click", function(e){
         console.log("reactivate nextel phones");
         if(nextelKnockedOutEdges.length > 0){
            cy.add(nextelKnockedOutEdges)
            nextelKnockedOutEdges = [];
            }
         resetReactivateMenu();
         });

      $("#reactivateVerizonPhonesMenuItem").on("click", function(e){
         console.log("reactivate Verizon phones");
         if(verizonKnockedOutEdges.length > 0){
            cy.add(verizonKnockedOutEdges)
            verizonKnockedOutEdges = [];
            }
         resetReactivateMenu();
         });

      $("#reactivateCellularOnePhonesMenuItem").on("click", function(e){
         console.log("reactivate cellular one phones");
         if(cellularOneKnockedOutEdges.length > 0){
            cy.add(cellularOneKnockedOutEdges)
            cellularOneKnockedOutEdges = [];
            }
         resetReactivateMenu();
         });

      $("#reactivateUSCellularPhonesMenuItem").on("click", function(e){
         console.log("reactivate us cellular phones");
         if(usCellularOneKnockedOutEdges.length > 0){
            cy.add(usCellularOneKnockedOutEdges)
            usCellularOneKnockedOutEdges = [];
            }
         resetReactivateMenu();
         });

     $('a.leafMenuItem').on("click", function(e){
        console.log("leafMenuItem click");
        console.log(e);
        $(this).next('ul').toggle();
        e.stopPropagation();
        e.preventDefault();
        });

     $("#knockoutWithoutEmailMenuItem").on("click", function(e){
        console.log("w/o email");
        var propertiedNodes = cy.filter(function(e){return (e.isNode() && !e.data("email"))});
        withoutEmailKnockedOutEdges = cy.remove(propertiedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     $("#knockoutWithoutRoamingMenuItem").on("click", function(e){
        console.log("w/o roaming");
        var propertiedNodes = cy.filter(function(e){return (e.isNode() && !e.data("roaming"))});
        withoutRoamingKnockedOutEdges = cy.remove(propertiedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     $("#knockoutWithoutPhotoMenuItem").on("click", function(e){
        console.log("w/o camera");
        var propertiedNodes = cy.filter(function(e){return (e.isNode() && !e.data("camera"))});
        withoutCameraKnockedOutEdges = cy.remove(propertiedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     $("#knockoutWithEmailMenuItem").on("click", function(e){
        var propertiedNodes = cy.filter(function(e){return (e.isNode() && e.data("email"))});
        withEmailKnockedOutEdges = cy.remove(propertiedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     $("#knockoutWithRoamingMenuItem").on("click", function(e){
        console.log("with roaming");
        var propertiedNodes = cy.filter(function(e){return (e.isNode() && e.data("roaming"))});
        withRoamingKnockedOutEdges = cy.remove(propertiedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     $("#knockoutWithCameraMenuItem").on("click", function(e){
        console.log("with camera");
        var propertiedNodes = cy.filter(function(e){return (e.isNode() && e.data("camera"))});
        withCameraKnockedOutEdges = cy.remove(propertiedNodes.connectedEdges())
        resetKnockoutMenu();
        });

     // reactivate menu code starts here

     $("#reactivateMainMenuButton").on("click", function(e){
        console.log("main menu button: reactivate");
        $("#reactivateMenuItems").toggle();
          // whether showing or hiding the first level menu
          // we always want the submenus hidden
        $("#reactivateByPropertiesMenuItems").hide();
        $("#reactivateByCarrierMenuItems").hide();
          // if another menu is up, hide it
        $("#knockoutMenuItems").hide()

        });

     $("#reactivateWithoutPropertyMenuHead").on("click", function(e){
        console.log("  phones without");
        $(this).next('ul').toggle();
        $("#reactivateWithPropertyMenuItems").hide();
        });

     $("#reactivateWithPropertyMenuHead").on("click", function(e){
        console.log("  phones with");
        $(this).next('ul').toggle();
        $("#reactivateWithoutPropertyMenuItems").hide();
        });

     $('#reactivateSelectedPhonesMenuItem').on("click", function(e){
        console.log("reactivateSelectedPhones");
        resetReactivateMenu();
        if(selectedNodesKnockedOutEdges.length > 0){
           cy.add(selectedNodesKnockedOutEdges)
           selectedNodesKnockedOutEdges = [];
           }
        });

     $('#reactivateByCarrierMenuHead').on("click", function(e){
        console.log("reactivateByCarrier");
        $("#reactivateByCarrierMenuItems").toggle()
        $('#reactivateByPropertiesMenuItems').hide()
        //resetReactivateMenu();
        });

     $("#reactivateByPropertiesMenuHead").on("click", function(e){
        console.log("reactivateByPropertiesMenuHead click");
          // toggle the "Phones with, Phones without submenu
        $('#reactivateByPropertiesMenuItems').toggle()
          // make sure the "By Carrier" menu is hidden
        $("#reactivateByCarrierMenuItems").hide()
          // make sure the sub-sub menus are both hidden
        $("#reactivateWithPropertyMenuHead").next("ul").hide()
        $("#reactivateWithoutPropertyMenuHead").next("ul").hide()
        });

     $("#reactivateTMobilePhonesMenuItem").on("click", function(e){
        console.log("reactivate t-mobile phones");
        if(tMobileKnockedOutEdges.length > 0){
           cy.add(tMobileKnockedOutEdges)
           tMobileKnockedOutEdges = [];
           }
        resetReactivateMenu();
        });

     $("#reactivateATTPhonesMenuItem").on("click", function(e){
         if(attKnockedOutEdges.length > 0){
            cy.add(attKnockedOutEdges)
            attKnockedOutEdges = [];
            }
        console.log("reactivate ATT phones");
        resetReactivateMenu();
        });

     $('a.leafMenuItem').on("click", function(e){
        console.log("leafMenuItem click");
        console.log(e);
        $(this).next('ul').toggle();
        e.stopPropagation();
        e.preventDefault();
        });

     $("#reactivateWithoutEmailMenuItem").on("click", function(e){
        console.log("w/o email");
        if(withoutEmailKnockedOutEdges.length > 0){
           cy.add(withoutEmailKnockedOutEdges);
           withoutEmailEmailKnockedOutEges = [];
           }
        resetReactivateMenu();
        });

     $("#reactivateWithoutRoamingMenuItem").on("click", function(e){
        console.log("w/o roaming");
        if(withoutRoamingKnockedOutEdges.length > 0){
           cy.add(withoutRoamingKnockedOutEdges);
           withoutRoamingKnockedOutEges = [];
           }
        resetReactivateMenu();
        });

     $("#reactivateWithoutPhotoMenuItem").on("click", function(e){
        console.log("w/o camera");
        if(withoutCameraKnockedOutEdges.length > 0){
           cy.add(withoutCameraKnockedOutEdges);
           withoutCameraKnockedOutEges = [];
           }
        resetReactivateMenu();
        });

     $("#reactivateWithEmailMenuItem").on("click", function(e){
        console.log("with email");
        if(withEmailKnockedOutEdges.length > 0){
            cy.add(withEmailKnockedOutEdges);
            withEmailKnockedOutEges = [];
           }
        resetReactivateMenu();
        });

     $("#reactivateWithRoamingMenuItem").on("click", function(e){
        console.log("with roaming");
        if(withRoamingKnockedOutEdges.length > 0){
            cy.add(withRoamingKnockedOutEdges);
            withRoamingKnockedOutEdges = [];
           }
        resetReactivateMenu();
        });

     $("#reactivateWithCameraMenuItem").on("click", function(e){
        console.log("with camera");
        if(withCameraKnockedOutEdges.length > 0){
            cy.add(withCameraKnockedOutEdges);
            withCameraKnockedOutEdges = [];
           }
        resetReactivateMenu();
        });

    }

} // module.exports
