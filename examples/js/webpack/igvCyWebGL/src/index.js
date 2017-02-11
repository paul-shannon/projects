module.exports = {};

var loadedModules = [
    require("./app"),
];

for (var i in loadedModules) {
  if (loadedModules.hasOwnProperty(i)) {
     var loadedModule = loadedModules[i];
     for (var target_name in loadedModule) {
        if (loadedModule.hasOwnProperty(target_name)) {
           module.exports[target_name] = loadedModule[target_name];
          }
        } // for
      } // if
  }// for i

