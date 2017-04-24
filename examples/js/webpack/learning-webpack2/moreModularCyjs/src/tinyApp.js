// tinyApp.js

module.exports = {

    init: function(){
       console.log("hello fromm tinyApp.init");
       },

    handleWindowResize: function(){
        console.log("tinyApp.handleWindowResize");
        console.log("=== window: ")
        console.log($(window));
        console.log("window height: ");
        console.log($(window).height());
        var outermostDivHeight = $("#outermostDiv").height();
        console.log("outermostDiv height: ");
        console.log(outermostDivHeight);
        var menubarHeight = $("#menubarDiv").height();
        var newHeight = outermostDivHeight - (menubarHeight + 20);

        console.log("==== newHeight: " + newHeight);
        $("#cyDiv").height(newHeight)
        }

}

