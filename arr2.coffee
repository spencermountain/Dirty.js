#make a mess
arr = ( (obj={soft:false}) ->

  arr= {}

  #a nicer version of typeof
  type = (obj) ->
    if obj == undefined or obj == null
      return String obj
    classToType = new Object
    for name in "Boolean Number String Function Array Date RegExp".split(" ")
      classToType["[object " + name + "]"] = name.toLowerCase()
    myClass = Object.prototype.toString.call obj
    if myClass of classToType
      return classToType[myClass]
    return "object"

  arr.grab =
    fn: (p) ->
      the = this
      if type(p) == "array"
        return the.map((s) ->
          p.map (f) ->
            s[f]
        )
      the.map (s) ->
        s[p]
    alias: ['collect','transform','pluck'],
    test: (arr1, objarr) ->
      equals objarr.grab("a"), [ 4, 9, null ]



  arr.print =
    fn: ->
      console.log JSON.stringify(this, null, 2),
    alias:[],
    description:"",
    test: (arr1, objarr) ->
      true

  arr.to_tsv =
    fn: ->
      console.log this.join("\t"),
    alias:["tsv"],
    description:"",
    test: (arr1, objarr) ->
      true

  arr.template =
    fn: (fn, join="\n")->
      this.map(fn).join(join)
    alias:["generate","html","to_string","haml"],
    description:"",
    test: (arr1, objarr) ->
      equals (arr1.generate (v) -> v), "1\n2\n3\n5\n3\n4"

  arr.clone =
    fn: ->
      JSON.parse JSON.stringify(this)
    alias:[],
    description:"",
    test: (arr1, objarr) ->
      equals [2].clone(), [2]

  arr.sum =
    fn: (field=null) ->
      if field
        return this.reduce((a, b) ->
          a + b[field]
        , 0)
      this.reduce ((a, b) ->
        a + b
      ), 0
    alias:["total"],
    description:"",
    test: (arr1, objarr) ->
      equals arr1.sum(), 18


  arr.percentage =
    fn: (fn=(v)->v) ->
      return 0 if this.length==0
      passes = this.filter(fn)
      parseInt (passes.length / this.length) * 100
    alias:["percent"],
    description:"",
    test: (arr1, objarr) ->
      equals arr1.percentage((v)->v>2), 66

  arr.average =
    fn:(field) ->
      return 0  if this.length is 0
      sum = 0
      if field
        sum = this.reduce((a, b) ->
          a + b[field]
        , 0)
      else
        sum = this.reduce((a, b) ->
          a + b
        , 0)
      sum / this.length
    alias:["mean"],
    description:"",
    test: (arr1, objarr) ->
      arr1.average() == 3


  arr.spigot =
    fn: (fn) ->
      the = this
      all =
        true: []
        false: []
      the.forEach (v) ->
        if fn(v)
          all["true"].push v
        else
          all["false"].push v
      all
    alias:["moses","faucet"],
    description:"",
    test: (arr1, objarr) ->
      equals arr1.spigot( (v) -> v>2 ), { true: [ 3, 5, 3, 4 ], false: [ 1, 2 ] }

  arr.duplicates =
    fn: (field) ->
      the = this
      the = the.grab(field)  if field
      the = the.sort()
      results = []
      i = 0
      while i < the.length - 1
        results.push the[i]  if the[i + 1] == the[i]
        i++
      results
    alias:["dupes","doubles"],
    description:"",
    test: (arr1, objarr) ->
      equals arr1.duplicates(), [3]

  arr.overlap =
    fn:(arr2) ->
      this.filter (v) ->
        arr2.some (v2) ->
          v is v2
    alias:["intersection"],
    description:"",
    test: (arr1, objarr) ->
      equals arr1.overlap([2,3]), [2,3,3]

  arr.topk=
    fn:()->
      the = this
      length = the.length or 1
      freq = {}
      i = the.length - 1
      while i > -1
        (if !freq[the[i]]? then freq[the[i]] = 1 else freq[the[i]]++)
        i--
      top = Object.keys(freq).sort((a, b) ->
        freq[b] - freq[a]
      )
      top.map (v) ->
        value: v
        count: freq[v]
    alias:["sort_by_freq"],
    description:"",
    test: (arr1, objarr) ->
      arr1.topk()[0].count == 2

  arr.flatten =
    fn:()->
      this.reduce ((a, b) ->
        a.concat b
      ), []
    alias:[""],
    description:"one-level flatten of arrays within arrays",
    test: (arr1, objarr) ->
      equals [1,2,[3],[[4,5],6]].flatten(), [ 1, 2, 3, [ 4, 5 ], 6 ]

  arr.shuffle =
    fn:()->
      this.sort (a, b) ->
        Math.round(Math.random()) - 0.5
    alias:[""],
    description:"randomize the order of an array",
    test: (arr1, objarr) ->
      arr1.shuffle().sum() == arr1.sum()


  arr.find=
    fn:(fn)->
      done= null
      this.some (v) ->
        if fn(v)
          done = v;
          return true;
        return false;
      done
    alias:[""],
    description:"get the first matching element of an array then stop looking",
    test: (arr1, objarr) ->
      equals objarr.find((o)->o.b==2), { a: 4, b: 2 }


  arr.first =
    fn: (filt) ->
      the= this
      if typeof(filt)=="undefined"
        return the[0]
      filt = filt or 1
      if type(filt) == "function"
        the.find(filt)
      else
       the.slice 0, filt
    alias:[""],
    description:"grab first matching element(s) of an array",
    test: (arr1, objarr) ->
      console.log arr1.first(2)
      equals arr1.first(2), [1,2]

  arr.last =
    fn: (filt) ->
      the= this.reverse()
      the.first(filt)
    alias:[""],
    description:"grab last matching element of an array",
    test: (arr1, objarr) ->
      console.log arr1.last()
      equals arr1.last(), [4]

  # arr.head =
  #   fn:(max=5) ->
  #     this.first max
  #   alias:["top"],
  #   description:"",
  #   test: (arr1, objarr) ->
  #     equals arr1.head(2), [3,5]

  # arr.sort_by =
  #   fn:(k) ->
  #     this.sort (a, b) ->
  #       b[k] - a[k]
  #   alias:[""],
  #   description:"",
  #   test: (arr1, objarr) ->
  #     console.log obj.sort_by("b")



  Object.keys(arr).forEach (i) ->
    Object.defineProperty Array::, i,
      value: arr[i].fn
      configurable: true
      enumerable: false
    arr[i].alias.forEach (a) ->
      Object.defineProperty Array::, a,
      value: arr[i].fn
      configurable: true
      enumerable: false

  return arr
)()



#tests
equals = (a1, a2) ->
  JSON.stringify(a1)==JSON.stringify(a2)

simplearr= [1,2,3,5,3,4]
objarr= [{a:4, b:2},{a:9},{b:8}]

Object.keys(arr).forEach (i) ->
  console.log i + " " + arr[i].test(simplearr, objarr)




#  r=[3,4,3,4,[5],6,0,null,7]
#   r.flatten().compact().print()

# dirty.undo()
# r={f:3,fe:2,q:99}
# x=r.map(function(s,i){return s})
# console.log(r.size())
# console.log(r.filter(function(v){return v<5}))
# console.log(r.filter(function(v,i){return i=="f"}))
# r.toarr().print()
#   r.print()

#  for(var i in r){
#   console.log(i)
#  }
# r=[2,3,4,5]
# r.overlap([3,4,88,8]).print()
#r.spigot(function(v){return v>3}).print()
#	 r=[{f:3},{f:2},{f:9}]
# var d=[1,2,4]

# r.spigot(function(v){return v.f.isin(d)}).print()
#r.sum('f').print()
#r.average('f').print()

# r.percentage(function(s){return s.f>2}).print()

# var results=["dan","tom","spencer",null]
# var wanted=["dan","spencer","john",null,"frank","bill","sam"]
#  results.mean_average_precision(wanted).print()
# // results.recall(wanted).print()


# simplearr= [1,2,3,5,3,4]
# objarr= [{a:4, b:2},{a:9},{b:8}]
# # console.log objarr.grab('a')

# console.log objarr.pluck('a')

# # objarr.print()
arr= [1,2,3,5,3,4]
# arr.print
# console.log arr.spigot (v) -> v>2

# console.log arr.generate (v) -> v

# console.log arr.average()