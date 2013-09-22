#make a mess
dirty = (->

  documentation = ->
    arr = []
    arr.push "##Object methods"
    Object.keys(fns.obj).forEach (v) ->
      arr.push "* __." + v + "__ ( ) "

    arr.push ""
    arr.push "##Array methods"
    Object.keys(fns.arr).forEach (v) ->
      arr.push "* __." + v + "__ ( )"

    arr.push ""
    arr.push "##Number methods"
    Object.keys(fns.num).forEach (v) ->
      arr.push "* __x." + v + "__ ( )"

    arr.push ""
    arr.push "##String methods"
    Object.keys(fns.str).forEach (v) ->
      arr.push "* __str." + v + "__ ( )"

    arr.join "\n"


  dirty = {}
  fns =
    arr: {}
    obj: {}
    num: {}
    str: {}
  redirects = {}
  descriptions = {}

  fns.arr.grab = (p) ->
    if typeof p is "object" and p.length
      return @map((s) ->
        p.map (f) ->
          s[f]

      )
    @map (s) ->
      s[p]


  fns.arr.collect = fns.arr.grab
  fns.arr.transform = fns.arr.grab
  fns.arr.prepend = Array::unshift
  fns.arr.append = Array::push
  fns.arr.clone = ->
    JSON.parse JSON.stringify(this)

  fns.arr.copy = fns.arr.clone
  fns.arr.stat = (callback) ->
    types = @map((v) ->
      if typeof v is "object"
        unless v?
          "null"
        else "array"  if v.length
      else
        typeof v
    ).topk(true)
    obj =
      length: @length
      types: types.map((v) ->
        parseInt(v.percentage) + "% " + v.value + "s"
      ).join(", ")
      dupes: @dupes().topk(true).map((v) ->
        [v.value, (v.count + 1)]
      ).to_obj()
      falsy: @length - @compact().length
      empty: @filter((v) ->
        return true  if Object::toString.call(v) is "[object Array]" and v.length is 0
        return true  if Object::toString.call(v) is "[object Object]" and v.keys.length is 0
        false
      ).length

    return callback(obj)  if callback
    console.log JSON.stringify(obj, null, 2)

  fns.arr.stats = fns.arr.stat
  fns.arr.spigot = (fn) ->
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

  fns.arr.moses = fns.arr.spigot
  fns.arr.max = (field) ->
    if field
      return @sort((a, b) ->
        b[field] - [field]
      )[0]
    Math.max.apply null, this

  fns.arr.mean_average_precision = (results) ->
    return 1  if results.length is 0 and @length is 0
    precisions = []
    found = 0
    @forEach (w, i) ->
      i++
      found++  if results.some((s) ->
        s is w
      )
      precision = found / i
      precisions.push precision

    precisions.average()

  fns.arr.to_tsv = ->
    console.log @join("\t")

  fns.arr.tsv = fns.arr.to_tsv
  fns.arr.recall = (wanted) ->
    results = this
    return 0  if wanted.length is 0
    overlap = results.overlap(wanted).length
    overlap / wanted.length

  fns.arr.precision = (wanted) ->
    results = this
    return 0  if results.length is 0
    overlap = results.overlap(wanted).length
    overlap / results.length

  fns.arr.sum = (field) ->
    if field
      return @reduce((a, b) ->
        a + b[field]
      , 0)
    @reduce ((a, b) ->
      a + b
    ), 0

  fns.arr.percentage = (fn) ->
    passes = @filter(fn)
    parseInt (passes.length / @length) * 100

  fns.arr.select = Array::filter
  fns.arr.must = fns.arr.select
  fns.arr.reject = (filter) ->
    if typeof filter is "function"
      @filter (v) ->
        not filter(v)

    else if typeof filter is "number" or typeof filter is "string"
      @filter (v) ->
        v isnt filter

    else if typeof filter is "object"
      filter = JSON.stringify(filter)
      @filter (v) ->
        JSON.stringify(v) isnt filter


  fns.arr.kill = fns.arr.reject
  fns.arr.remove = fns.arr.reject
  fns.arr.average = (field) ->
    return 0  if @length is 0
    sum = 0
    if field
      sum = @reduce((a, b) ->
        a + b[field]
      , 0)
    else
      sum = @reduce((a, b) ->
        a + b
      , 0)
    sum / @length

  fns.arr.mean = fns.arr.average
  fns.arr.strings = ->
    @filter (v) ->
      typeof v is "string"


  fns.arr.numbers = ->
    @filter (v) ->
      typeof v is "object"


  fns.arr.objects = ->
    @filter (v) ->
      typeof v is "object"


  fns.arr.truthy = ->
    @filter (v) ->
      v


  fns.arr.duplicates = (field) ->
    arr = this
    arr = arr.grab(field)  if field
    arr = arr.sort()
    results = []
    i = 0

    while i < arr.length - 1
      results.push arr[i]  if arr[i + 1] is arr[i]
      i++
    results

  fns.arr.dupes = fns.arr.duplicates
  fns.arr.overlap = (arr2) ->
    @filter (v) ->
      arr2.some (v2) ->
        v is v2



  fns.arr.intersection = fns.arr.overlap
  fns.arr.isin = fns.arr.overlap
  fns.arr.just = fns.arr.overlap
  fns.arr.missing_from = (arr2) ->
    @filter (v) ->
      not arr2.some((v2) ->
        v is v2
      )


  fns.arr.has_overlap = (arr2) ->
    @some (v) ->
      arr2.some (v2) ->
        v is v2



  fns.arr.overlaps = fns.arr.has_overlap
  fns.arr.topk = (verbose) ->
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


  fns.arr.freq = fns.arr.topk
  fns.arr.frequency = fns.arr.topk
  fns.arr.each = (fn) ->
    @forEach fn

  fns.arr.loop = fns.arr.each
  fns.arr.uniq = ->
    u = {}
    a = []
    i = 0
    l = @length

    while i < l
      continue  if u.hasOwnProperty(this[i])
      a.push this[i]
      u[this[i]] = 1
      ++i
    a

  fns.arr.unique = fns.arr.uniq
  fns.arr.uniq_by = fns.arr.uniq
  fns.arr.unique_by = fns.arr.uniq
  fns.arr.compact = ->
    @filter (v) ->
      return false  if Object::toString.call(v) is "[object Array]" and v.length is 0
      return false  if Object::toString.call(v) is "[object Object]" and v.keys.length is 0
      v is 0 or v


  fns.arr.flatten = ->
    @reduce ((a, b) ->
      a.concat b
    ), []

  fns.arr.print = ->
    console.log JSON.stringify(this, null, 2)

  fns.arr.printf = fns.arr.print
  fns.arr.console = fns.arr.print
  fns.arr.log = fns.arr.print
  fns.arr.shuffle = ->
    @sort (a, b) ->
      Math.round(Math.random()) - 0.5


  fns.arr.randomize = fns.arr.shuffle
  fns.arr.group_by = (str) ->
    obj = {}
    @forEach (t) ->
      unless obj[t[str]]
        obj[t[str]] = [t]
      else
        obj[t[str]].push t

    obj

  fns.arr.chunk_by = (group_length) ->
    all = []
    arr = this
    group_length = group_length or 1
    for i of arr
      if i % group_length is 0
        all.push [arr[i]]
      else
        all[all.length - 1].push arr[i]
    all

  fns.arr.toobject = (values) ->
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

  fns.arr.to_obj = fns.arr.toobject
  fns.arr.spotcheck = (max) ->
    max = max or 10
    x = @randomize()
    x.slice 0, max

  fns.arr.first = (filt) ->
    filt = filt or 1
    if typeof filt is "function"
      match = undefined
      @some (v) ->
        if filt(v)
          match = v
          true
        else
          false

      match
    else @slice 0, filt  if typeof filt is "number"

  fns.arr.top = fns.arr.first
  fns.arr.last = ->
    this[@length - 1]

  fns.arr.head = (max) ->
    max = max or 10
    fns.arr.first max

  fns.arr.sort_by = (k) ->
    @sort (a, b) ->
      b[k] - a[k]


  fns.obj.values = ->
    obj = this
    Object.keys(this).map (v) ->
      obj[v]


  fns.obj.keys = ->
    Object.keys this

  fns.obj.map = (fn) ->
    obj = this
    Object.keys(this).map (v) ->
      fn obj[v], v


  fns.obj.each = (fn) ->
    obj = this
    Object.keys(this).map (v) ->
      fn obj[v], v


  fns.obj.toarr = ->
    arr = []
    for i of this
      arr.push [i, this[i]]
    arr

  fns.obj.to_arr = fns.obj.toarr
  fns.obj.to_a = fns.obj.toarr
  fns.obj.size = ->
    size = 0
    key = undefined
    for key of this
      size += 1  if @hasOwnProperty(key)
    size

  fns.obj.filter = (fn) ->
    obj = this
    arr = Object.keys(this).filter((v) ->
      fn obj[v], v
    )
    newobj = {}
    arr.forEach (a) ->
      newobj[a] = obj[a]

    newobj

  fns.obj.extend = (obj) ->
    for i of obj
      this[i] = obj[i]
    this

  fns.obj.combine = fns.obj.extend
  fns.obj.add = fns.obj.extend
  fns.obj.print = ->
    console.log JSON.stringify(this, null, 2)

  fns.obj.printf = fns.obj.print
  fns.obj.log = fns.obj.print
  fns.obj.stats = ->
    @to_arr().stat()

  fns.obj.stat = fns.obj.stats
  fns.obj.sort = (fn) ->
    fn = fn or ->

    newobj = {}
    oldobj = this
    @keys().sort(fn).forEach (v) ->
      newobj[v] = oldobj[v]

    newobj

  fns.obj.sort_keys = fns.obj.sort
  fns.obj.sort_values = ->
    @to_arr().sort_by([1]).to_obj()

  fns.obj.to_tsv = ->
    console.log @values().join("\t")

  fns.obj.tsv = fns.obj.to_tsv
  fns.str.isin = (arr) ->
    word = this
    arr.some (v) ->
      word is v


  fns.num.roof = (max) ->
    return max  if this > max
    this

  fns.num.ceiling = fns.num.roof
  fns.num.max = fns.num.roof
  fns.num.floor = (min) ->
    return min  if this < min
    this

  fns.num.min = fns.num.floor
  fns.num.ground = fns.num.floor

  fns.num.to_date = () ->
    d= new Date();
    d.setTime(this)
    d
  fns.num.date= fns.num.to_date


  fns.num.to = (stop, step) ->
    start = this
    return []  if not stop? or stop is `undefined` or stop is start
    step = step or 1
    arr = []
    if stop > start
      i = start

      while i <= stop
        arr.push i
        i += step
    else
      i = start

      while i >= stop
        arr.push i
        i -= step
    arr

  fns.num.upto = fns.num.to
  fns.num.ordinalize = ->
    n = this
    switch n % 10
      when 1
        n + "st"
      when 2
        n + "nd"
      when 3
        n + "rd"
      else
        n + "th"

  fns.num.ordinal = fns.num.ordinalize
  fns.num.suffix = fns.num.ordinalize
  fns.num.ordinate = fns.num.ordinalize
  Object.keys(fns.obj).forEach (i) ->
    Object.defineProperty Object::, i,
      value: fns.obj[i]
      configurable: true
      enumerable: false


  Object.keys(fns.arr).forEach (i) ->
    Object.defineProperty Array::, i,
      value: fns.arr[i]
      configurable: true
      enumerable: false


  Object.keys(fns.str).forEach (i) ->
    Object.defineProperty String::, i,
      value: fns.str[i]
      configurable: true
      enumerable: false


  Object.keys(fns.num).forEach (i) ->
    Object.defineProperty Number::, i,
      value: fns.num[i]
      configurable: true
      enumerable: false


  dirty.undo = ->
    Object.keys(fns).forEach (i) ->
      Object.defineProperty Array::, i,
        value: `undefined`



  dirty.fix = dirty.undo
  dirty.clean = dirty.undo
  dirty.cleanup = dirty.undo
  if typeof define isnt "undefined" and define.amd
    define [], ->
      dirty

  else module.exports = dirty  if typeof module isnt "undefined" and module.exports

  #console.log(documentation())
  dirty
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
#r=[2,3,4,5]
#r.overlap([3,4,88,8]).print()
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

# arr=[1,2,3,3,null,[3],2]

# x=99
# x=x.ceiling(90)
# x.print()