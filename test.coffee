require("sugar")
require("./dirty")

# arr= [1,2,3,4,5,6,7,8,9]
# console.log arr.prefer (x)-> x==0
# arr= [1,2,3,4,5,6,7,8,9]
# console.log arr.overlaps([99])

x= 6
x= x.atleast(6)
# x= x.under(6)
console.log x