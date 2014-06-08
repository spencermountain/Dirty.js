Array.extend
  sentence: (conjunction) ->
    sentence = ""
    twoWordConjunction = undefined
    lastWordConjunction = undefined
    return sentence  if @length is 0
    conjunction = "and"  if typeof conjunction isnt "string"
    twoWordConjunction = " " + conjunction + " "
    lastWordConjunction = " " + conjunction + " "
    switch @length
      when 1
        sentence = this[0]
      when 2
        sentence = @join(twoWordConjunction)
      else
        sentence = @first(@length - 1).join(", ") + lastWordConjunction + @last()
    sentence

  spigot:(fn) ->
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

  moses:(fn) ->
    the.spigot(fn)

  duplicates:(field) ->
      the = this
      the = the.grab(field)  if field
      the = the.sort()
      results = []
      i = 0
      while i < the.length - 1
        results.push the[i]  if the[i + 1] == the[i]
        i++
      results

  overlap:(arr2) ->
      this.filter (v) ->
        arr2.some (v2) ->
          v is v2

  overlaps:(arr2) ->
      this.some (v) ->
        arr2.some (v2) ->
          v is v2

  topk:(f)->
    arr= this
    neats= arr
    if f
      neats= arr.map(f)
    obj= neats.reduce( (h,r)->
      r= JSON.stringify(r) if typeof r =="object"
      h[r] = 0 if !h[r]
      h[r]++
      h
    , {})
    top = Object.keys(obj).sort((a, b) ->
      obj[b] - obj[a]
    )
    top.map (v) ->
      original= v
      if f
        original= arr.find (a)-> JSON.stringify(a[f])==JSON.stringify(v)
      value: original
      count: obj[v]

  topkp:(f)->
    arr= this
    count= arr.length || 0
    return arr.topk(f).map (t)->
      t.percent= ((t.count/count)*100).toFixed(2);
      t


  print:()->
      console.log JSON.stringify(this, null, 2)

  random:()->
    arr= this
    arr[Math.floor(Math.random()*arr.length)]

  has:(f)->
    this.some(f)

  includes:(f)->
    this.some(f)

  not_in:(arr2)->
    this.filter (a)->
      !arr2.some(a)

  yesmap:(fn)->
    this.map((x)->fn(x)).compact()

  hasmap:(fn)->
    arr= this
    if fn
      arr= arr.map(fn)
    return arr.reduce((h,o)->
      h[o]=true
      h
    ,{})

  firstmap:(fn)->
    x= this.find((x)->fn(x))
    if x
      return fn(x)

  equals:(b)->
    a= this
    return true  if a is b
    return false  if not a? or not b?
    return false  unless a.length is b.length
    # If you don't care about the order of the elements inside the array, you should sort both arrays here.
    i = 0
    while i < a.length
      return false  if a[i] isnt b[i]
      ++i
    true

  prefer:(fn)->
    arr= this
    obj= arr.spigot fn
    a= obj.true||[]
    a.concat(obj.false)

  bury:(fn)->
    arr= this
    obj= arr.spigot fn
    a= obj.false||[]
    a.concat(obj.true)


Number.extend
  #do something only n person of the time
  percent:(fn)->
    if this >= Math.floor(Math.random()*100)
      fn()
  percent_distributed:(fn1, fn2)->
    if this >= Math.floor(Math.random()*100)
      fn1()
    else
      fn2()
  percent_of:(x)->
    return 0 if num==0 || x==0
    num= this/100
    x * num
  delay:(fn)->
    num= this
    setTimeout(fn,num)
  random:()->
    Math.floor(Math.random()*this)
  randomto:(to=100)->
    num= this
    Math.floor(Math.random()*to)+num
  in:(arr)->
    num= this
    arr.some(num)
  is_in:(arr)->
    num= this
    arr.some(num)
  choosenot:(nay)->
    count= 0
    upto= this
    choose=->
      x= Math.floor(Math.random()*upto)
      if x==nay && count<30
        count++
        choose()
      else
        return x
    choose()
  under:(i)->
    num= parseInt(this)
    if num > i
      return i
    else
      return num
  below:(i)->
    return this.under(i)

  atleast:(i)->
    num= parseInt(this)
    if num < i
      return i
    else
      return num
  above:(i)->
    return this.atleast(i)

Object.extend
  to_a:(obj)->
    x= []
    Object.each obj, (k,v)->
      x.push [k, v]
    x

  #find the strongest correllations between a key and its values
  signals:(o)->
    better= {}
    Object.keys(o).forEach (k)->
      arr= o[k].topkp()
      better[k]=arr

    best= []
    Object.keys(better).forEach (k)->
      better[k].forEach (combo)->
        confidence= combo.percent * combo.count
        best.push({key:k, value:combo.value, count:combo.count,  percent:combo.percent, confidence:confidence})
    best= best.sort (a,b)->
      return b.confidence - a.confidence
    best= best.unique('key')
    return best


  #merge an array of objects, push one into the other when a conflict
  combine:(arr)->
    f= arr[0]
    arr.removeAt(0).each (obj)->
      f= Object.merge(f, obj, false, (key, a, b)->
        a= [a] if !Array.isArray a
        a.concat b
      )
    f