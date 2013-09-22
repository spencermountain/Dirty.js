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

  topk:()->
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

  print:()->
      console.log JSON.stringify(this, null, 2)

  random:()->
    arr= this
    arr[Math.floor(Math.random()*arr.length)]


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
  delay:(fn)->
    num= this
    setTimeout(fn,num)
  randomto:(to=100)->
    num= this
    Math.floor(Math.random()*to)+num