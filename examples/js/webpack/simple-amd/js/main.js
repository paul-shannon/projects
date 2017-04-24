require(['module1', 'sub1/module2'], function(module1ref, module2ref){
   var module1 = new module1ref();
   var module2 = new module2ref();
   console.log(module1.getName() === module2.getModule1Name()); // true
   });
