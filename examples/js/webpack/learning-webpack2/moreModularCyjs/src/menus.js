function foo(){
    var x = 99;
    console.log(x);
    };

function resetKnockoutMenu(){
        console.log("resetKnockoutMenu");
        $("#knockoutByCarrierMenuItems").hide();
        //$("#knockoutWithoutPropertyMenuHead").hide()
        $("#knockoutByPropertiesMenuItems").hide();
        $("#knockoutWithPropertyMenuItems").hide();
        //$("#knockoutWithoutPropertyMenuItems").hide();
        $("#knockoutByCarrierMenuItems").hide();
        $("#knockoutMenuItems").hide();
};

function resetReactivateMenu (){
        console.log("resetReactivateMenu");
        $("#reactivateByCarrierMenuItems").hide();
        //$("#reactivateWithoutPropertyMenuHead").hide()
        $("#reactivateByPropertiesMenuItems").hide();
        $("#reactivateWithPropertyMenuItems").hide();
        //$("#reactivateWithoutPropertyMenuItems").hide();
        $("#reactivateByCarrierMenuItems").hide();
        $("#reactivateMenuItems").hide();
};

module.exports = {

    xresetKnockoutMenu: function(){
        console.log("resetKnockoutMenu");
        $("#knockoutByCarrierMenuItems").hide();
        //$("#knockoutWithoutPropertyMenuHead").hide()
        $("#knockoutByPropertiesMenuItems").hide();
        $("#knockoutWithPropertyMenuItems").hide();
        //$("#knockoutWithoutPropertyMenuItems").hide();
        $("#knockoutByCarrierMenuItems").hide();
        $("#knockoutMenuItems").hide();
        },

    xresetReactivateMenu: function(){
        console.log("resetReactivateMenu");
        $("#reactivateByCarrierMenuItems").hide();
        //$("#reactivateWithoutPropertyMenuHead").hide()
        $("#reactivateByPropertiesMenuItems").hide();
        $("#reactivateWithPropertyMenuItems").hide();
        //$("#reactivateWithoutPropertyMenuItems").hide();
        $("#reactivateByCarrierMenuItems").hide();
        $("#reactivateMenuItems").hide();
        },

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
          //e.stopPropagation();
          //e.preventDefault();
        });

     /**********
     $('.dropdown-submenu a.test').on("click", function(e){
     console.log("submenu click");
     console.log(e);
     $(this).next('ul').toggle();
     e.stopPropagation();
     e.preventDefault();
     });
     ********/

     $("#knockoutTMobilePhonesMenuItem").on("click", function(e){
        console.log("knockout t-mobile phones");
        resetKnockoutMenu();
        });

     $("#knockoutSprintPhonesMenuItem").on("click", function(e){
        console.log("knockout sprint phones");
        resetKnockoutMenu();
        });

     $("#knockoutATTPhonesMenuItem").on("click", function(e){
        console.log("knockout ATT phones");
        resetKnockoutMenu();
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
        resetKnockoutMenu();
        });

     $("#knockoutWithoutRoamingMenuItem").on("click", function(e){
        console.log("w/o roaming");
        resetKnockoutMenu();
        });

     $("#knockoutWithoutPhotolMenuItem").on("click", function(e){
        console.log("w/o photo");
        resetKnockoutMenu();
        });

     $("#knockoutWithEmailMenuItem").on("click", function(e){
        console.log("with email");
        resetKnockoutMenu();
        });

     $("#knockoutWithRoamingMenuItem").on("click", function(e){
        console.log("with roaming");
        resetKnockoutMenu();
        });

     $("#knockoutWithPhotolMenuItem").on("click", function(e){
        console.log("with photo");
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

     $('#reactivateByCarrierMenuHead').on("click", function(e){
        console.log("reactivateByCarrierMenuHead click");
        $("#reactivateByCarrierMenuItems").toggle()
        $('#reactivateByPropertiesMenuItems').hide()
          //e.stopPropagation();
          //e.preventDefault();
        });

     /**********
     $('.dropdown-submenu a.test').on("click", function(e){
     console.log("submenu click");
     console.log(e);
     $(this).next('ul').toggle();
     e.stopPropagation();
     e.preventDefault();
     });
     ********/

     $("#reactivateTMobilePhonesMenuItem").on("click", function(e){
        console.log("reactivate t-mobile phones");
        resetReactivateMenu();
        });

     $("#reactivateSprintPhonesMenuItem").on("click", function(e){
        console.log("reactivate sprint phones");
        resetReactivateMenu();
        });

     $("#reactivateATTPhonesMenuItem").on("click", function(e){
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
        resetReactivateMenu();
        });

     $("#reactivateWithoutRoamingMenuItem").on("click", function(e){
        console.log("w/o roaming");
        resetReactivateMenu();
        });

     $("#reactivateWithoutPhotolMenuItem").on("click", function(e){
        console.log("w/o photo");
        resetReactivateMenu();
        });

     $("#reactivateWithEmailMenuItem").on("click", function(e){
        console.log("with email");
        resetReactivateMenu();
        });

     $("#reactivateWithRoamingMenuItem").on("click", function(e){
        console.log("with roaming");
        resetReactivateMenu();
        });

     $("#reactivateWithPhotolMenuItem").on("click", function(e){
        console.log("with photo");
        resetReactivateMenu();
        });

    }

} // module.exports
