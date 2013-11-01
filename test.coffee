require("sugar")
require("./dirty")

obja=
  fun:1,
  cool:[1,9]

objb=
  fun:3,
  cool:2

objb2=
  fun:3,
  cool:1

objc=
  fun:"cc",
  cool:"c"

# console.log Object.combine([obja,objb, objc])


console.log Object.to_a(objc)

# x= [obja, objb, obja].topk('fun')
# console.log(JSON.stringify(x, null, 2));

# console.log [1,{f:2},2,2,3].topk()