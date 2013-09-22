#make a mess
arr = (->

  arr= {}
  alias = {}
  blurb = {}
  test = {}

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

  arr.grab = (p) ->
    if type p == "array"
      return this.map((s) ->
        p.map (f) ->
          s[f]
      )
    this.map (s) ->
      s[p]
  alias.grab= ['collect','transform','pluck']
  test.grab= [
      [ [{a:4, b:2},{a:9},{b:8}].grab('a'), [4,9,null] ]
    ]

  arr.prepend = Array::unshift
  arr.append = Array::push
  arr.clone = ->
    JSON.parse JSON.stringify(this)

  arr.copy = arr.clone

  arr.spigot = (fn) ->
    arr = this
    all =
      true: []
      false: []

    arr.forEach (v) ->
      if fn(v)
        all["true"].push v
      else
        all["false"].push v

    all

  arr.moses = arr.spigot
  arr.max = (field) ->
    if field
      return this.sort((a, b) ->
        b[field] - [field]
      )[0]
    Math.max.apply null, this

  arr.mean_average_precision = (results) ->
    return 1  if results.length is 0 and this.length is 0
    precisions = []
    found = 0
    this.forEach (w, i) ->
      i++
      found++  if results.some((s) ->
        s is w
      )
      precision = found / i
      precisions.push precision

    precisions.average()

  arr.to_tsv = ->
    console.log this.join("\t")

  arr.tsv = arr.to_tsv
  arr.recall = (wanted) ->
    results = this
    return 0  if wanted.length is 0
    overlap = results.overlap(wanted).length
    overlap / wanted.length

  arr.precision = (wanted) ->
    results = this
    return 0  if results.length is 0
    overlap = results.overlap(wanted).length
    overlap / results.length

  arr.sum = (field) ->
    if field
      return this.reduce((a, b) ->
        a + b[field]
      , 0)
    this.reduce ((a, b) ->
      a + b
    ), 0

  arr.percentage = (fn) ->
    passes = this.filter(fn)
    parseInt (passes.length / this.length) * 100

  arr.select = Array::filter
  arr.must = arr.select
  arr.reject = (filter) ->
    if type filter is "function"
      this.filter (v) ->
        not filter(v)
    else if type filter is "number" or type filter is "string"
      this.filter (v) ->
        v isnt filter
    else if type filter is "object"
      filter = JSON.stringify(filter)
      this.filter (v) ->
        JSON.stringify(v) isnt filter


  arr.kill = arr.reject
  arr.remove = arr.reject
  arr.average = (field) ->
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

  arr.mean = arr.average
  arr.strings = ->
    this.filter (v) ->
      type v is "string"


  arr.numbers = ->
    this.filter (v) ->
      type v is "object"


  arr.objects = ->
    this.filter (v) ->
      type v is "object"


  arr.truthy = ->
    this.filter (v) ->
      v


  arr.duplicates = (field) ->
    arr = this
    arr = arr.grab(field)  if field
    arr = arr.sort()
    results = []
    i = 0
    while i < arr.length - 1
      results.push arr[i]  if arr[i + 1] is arr[i]
      i++
    results

  arr.dupes = arr.duplicates
  arr.overlap = (arr2) ->
    this.filter (v) ->
      arr2.some (v2) ->
        v is v2



  arr.intersection = arr.overlap
  arr.isin = arr.overlap
  arr.just = arr.overlap
  arr.missing_from = (arr2) ->
    this.filter (v) ->
      not arr2.some((v2) ->
        v is v2
      )


  arr.has_overlap = (arr2) ->
    this.some (v) ->
      arr2.some (v2) ->
        v is v2



  arr.overlaps = arr.has_overlap
  arr.topk = (verbose) ->
    myArray = this
    newArray = []
    length = myArray.length or 1
    freq = {}
    i = myArray.length - 1
    i = undefined

    while i > -1
      value = myArray[i]
      (if not freq[value]? then freq[value] = 1 else freq[value]++)
      i--
    for value of freq
      newArray.push value
    newArray = newArray.sort((a, b) ->
      freq[b] - freq[a]
    ).map((v) ->
      value: v
      count: freq[v]
      percentage: ((freq[v] / length) * 100).toFixed(2)
    )
    if verbose
      newArray
    else
      newArray.map (s) ->
        s.value


  arr.freq = arr.topk
  arr.frequency = arr.topk
  arr.each = (fn) ->
    this.forEach fn

  arr.loop = arr.each
  arr.uniq = ->
    u = {}
    a = []
    i = 0
    l = this.length

    while i < l
      continue  if u.hasOwnProperty(this[i])
      a.push this[i]
      u[this[i]] = 1
      ++i
    a

  arr.unique = arr.uniq
  arr.uniq_by = arr.uniq
  arr.unique_by = arr.uniq
  arr.compact = ->
    this.filter (v) ->
      return false  if Object::toString.call(v) is "[object Array]" and v.length is 0
      return false  if Object::toString.call(v) is "[object Object]" and v.keys.length is 0
      v is 0 or v


  arr.flatten = ->
    this.reduce ((a, b) ->
      a.concat b
    ), []

  arr.print = ->
    console.log JSON.stringify(this, null, 2)

  arr.printf = arr.print
  arr.console = arr.print
  arr.log = arr.print
  arr.shuffle = ->
    this.sort (a, b) ->
      Math.round(Math.random()) - 0.5


  arr.randomize = arr.shuffle
  arr.group_by = (str) ->
    obj = {}
    this.forEach (t) ->
      unless obj[t[str]]
        obj[t[str]] = [t]
      else
        obj[t[str]].push t

    obj

  arr.chunk_by = (group_length) ->
    all = []
    arr = this
    group_length = group_length or 1
    for i of arr
      if i % group_length is 0
        all.push [arr[i]]
      else
        all[all.length - 1].push arr[i]
    all

  arr.toobject = (values) ->
    list = this
    return {}  unless list?
    result = {}
    i = 0
    l = list.length

    while i < l
      if values
        result[list[i]] = values[i]
      else
        result[list[i][0]] = list[i][1]
      i++
    result

  arr.to_obj = arr.toobject
  arr.spotcheck = (max) ->
    max = max or 10
    x = this.randomize()
    x.slice 0, max

  arr.first = (filt) ->
    filt = filt or 1
    if typeof filt is "function"
      match = undefined
      this.some (v) ->
        if filt(v)
          match = v
          true
        else
          false
      match
    else this.slice 0, filt  if typeof filt is "number"

  arr.top = arr.first
  arr.last = ->
    this[this.length - 1]

  arr.head = (max) ->
    max = max or 10
    arr.first max

  arr.sort_by = (k) ->
    this.sort (a, b) ->
      b[k] - a[k]



  Object.keys(arr).forEach (i) ->
    Object.defineProperty Array::, i,
      value: arr[i]
      configurable: true
      enumerable: false

)()

#  r=[3,4,3,4,[5],6,0,null,7]
#   r.flatten().compact().print()

# dirty.undo()
# r={f:3,fe:2,q:99}
# x=r.map(function(s,i){return s})
#x.print()
# console.log(r.size())
# console.log(r.filter(function(v){return v<5}))
# console.log(r.filter(function(v,i){return i=="f"}))
# r.toarr().print()
#   r.print()

#  for(var i in r){
#   console.log(i)
#  }
r=[2,3,4,5]
r.overlap([3,4,88,8]).print()
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

