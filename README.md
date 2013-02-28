Dirty-prototype-manipulation
==========================

its like prototype or underscore, but it appends the built-in prototypes, which is bad practice

but dammit if this doesn't feel good:
  
     var data=[1,2,3,3,null,[3]]
     data.uniq().flatten().sort().print()


     npm install dirty

     var dirty=require("dirty")

to clean-up the mess afterwards:
     dirty.cleanup()