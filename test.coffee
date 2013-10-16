require("sugar")
require("./dirty")

obja=
  fun:1,
  cool:[1,9]

objb=
  fun:3,
  cool:2

objc=
  fun:"cc",
  cool:"c"

console.log Object.combine([obja,objb, objc])