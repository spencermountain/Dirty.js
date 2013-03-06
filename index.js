//make a mess

var dirty=(function(){
	var dirty={};

	var fns={}

	fns.grab=function(p){
							return this.map(function(s){
								return s[p]
							})
						}
	fns.collect=fns.grab;


	fns.clone=function(){
							return JSON.parse(JSON.stringify(this))
						}
	fns.copy=fns.clone;

	//split an array into passes and fails
	fns.spigot=function(fn){
		var arr=this;
		var all={"true":[],"false":[]}
		arr.forEach(function(v){
			if(fn(v)){
				all["true"].push(v)
			}else{
				all["false"].push(v)
			}
		});
		return all;
	}
	fns.moses=fns.spigot;

fns.max=function(field){
	if(field){
		 return this.sort(function(a,b){return b[field]-[field]})[0]
	}
	 return Math.max.apply(null, this)
}

//an accuracy score
fns.mean_average_precision=function(results){
	var precisions=[];
	var found=0;
	this.forEach(function(w,i){
	  i++
	  if(w.isin(results)){
	  	found++;
	  }
	  var precision=found/i;
	  precisions.push(precision)
	})
	return precisions.average()
}


fns.recall=function(wanted){
	var results=this;
	if(wanted.length===0){return 0;}
	var overlap=results.overlap(wanted).length;
	return overlap/wanted.length
}

fns.precision=function(wanted){
	var results=this;
	if(results.length===0){return 0;}
	var overlap=results.overlap(wanted).length;
	return overlap/results.length
}

//add em up
fns.sum=function(field){
	if(field){
		return this.reduce(function(a, b) {
	    return a + b[field];
		},0);
	}
	return this.reduce(function(a, b) {
	    return a + b;
	},0);
}

// % of array that pass a test
fns.percentage=function(fn){
	var passes=this.filter(fn);
	return parseInt((passes.length/this.length)*100)
}

fns.average=function(field){
	var sum=0
	if(field){
		sum= this.reduce(function(a, b) {
	    return a + b[field];
		},0);
	}else{
		sum= this.reduce(function(a, b) {
	    return a + b;
		},0);
	}
	return sum/this.length
}
fns.mean=fns.average;


fns.strings=function(){
	return this.filter(function(v){
		return typeof v=="string"
	})
}

fns.numbers=function(){
	return this.filter(function(v){
		return typeof v=="object"
	})
}

fns.objects=function(){
	return this.filter(function(v){
		return typeof v=="object"
	})
}

fns.truthy=function(){
	return this.filter(function(v){
		return v
	})
}

fns.duplicates=function(field) {
	var arr=this;
	if(field){arr=arr.grab(field);}
	arr=arr.sort();
	var results = [];
	for (var i = 0; i < arr.length - 1; i++) {
	    if (arr[i + 1] == arr[i]) {
	        results.push(arr[i]);
	    }
	}
	return results
}

fns.overlap=function(arr2){
  return this.filter(function(v){
  	return arr2.some(function(v2){return v===v2})
  })
}
fns.intersection=fns.overlap

//arr minus
fns.missing_from=function(arr2){
  return this.filter(function(v){
  	return !arr2.some(function(v2){return v===v2})
  })
}


fns.has_overlap=function(arr2){
  return this.some(function(v){
  	return arr2.some(function(v2){return v===v2})
  })
}
fns.overlaps=fns.has_overlap



fns.topk=function(verbose){
	var myArray=this;
	var newArray = [];
	var length=myArray.length ||1
	var freq = {};
	//Count Frequency of Occurances
	var i=myArray.length-1;
	for (var i;i>-1;i--)
	{
	  var value = myArray[i];
	  freq[value]==null?freq[value]=1:freq[value]++;
	}
	//convert to sortable array
	for (var value in freq)
	{
	  newArray.push(value);
	}
	newArray=newArray.sort(function(a,b){return freq[b]-freq[a];}).map(function(v){
		return {value:v, count:freq[v], percentage: ((freq[v]/length)*100).toFixed(2)}
	});
	if(verbose){
		return newArray
	}else{
		return newArray.map(function(s){return s.value})
	}
}
fns.freq=fns.topk
fns.frequency=fns.topk

	fns.each=function(fn){
						 this.forEach(fn)
						}
	fns.loop=fns.each;

//nulls or undefined
	fns.uniq=function(field){
			 	 var x=this;
			 	 if(!field){
				   var newArray=new Array();
				    label:for(var i=0; i<x.length;i++ ){
				      for(var j=0; j<newArray.length;j++ ){ 
				          if(newArray[j]==x[i]) 
				          continue label;
				        }
				        newArray[newArray.length] = x[i];
				      }
				    return newArray;
				  }else{
				   var newArray=new Array();
				    label:for(var i=0; i<x.length;i++ ){
				      for(var j=0; j<newArray.length;j++ ){ 
				          if(newArray[j][field]==x[i][field]) 
				          continue label;
				        }
				        newArray[newArray.length] = x[i];
				      }
				    return newArray;
			  	}
			  }
	fns.unique=fns.uniq
	fns.uniq_by=fns.uniq
	fns.unique_by=fns.uniq

		//remove nulls
	fns.compact=function(){
					return this.filter(function(v){return v===0||v})
				}

		//remove nested arrays one step
	fns.flatten=function(){
					    var flat = [];
					    var array=this;
					    for (var i = 0, l = array.length; i < l; i++){
					        var type = Object.prototype.toString.call(array[i]).split(' ').pop().split(']').shift().toLowerCase();
					        if (type) { flat = flat.concat(/^(array|collection|arguments|object)$/.test(type) ? Array.prototype.flatten(array[i]) : array[i]); }
					    }
					    return flat;
					}

		//pretty-print
	fns.print=function(){
				console.log(JSON.stringify(this, null, 2));
			}
	fns.printf=fns.print
	fns.console=fns.print
	fns.log=fns.print


	fns.shuffle=function(){
		return this.sort(function(a,b){return (Math.round(Math.random())-0.5);})
	}
	fns.randomize=fns.shuffle;


fns.group_by=function(str){
  var obj={}
  this.forEach(function(t){
    if(!obj[t[str]]){
      obj[t[str]]=[t]
    }else{
      obj[t[str]].push(t)
    }
  })
  return obj
}




fns.chunk_by=function(group_length){
	var all=[]
	var arr=this;
	group_length=group_length||1;
	for(var i in arr){
		if(i%group_length==0){
			all.push([arr[i]])
		}else{
			all[all.length-1].push(arr[i])
		}
	}
	return all
  }


fns.toobject = function(values) {
		var list=this;
    if (list == null) return {};
    var result = {};
    for (var i = 0, l = list.length; i < l; i++) {
      if (values) {
        result[list[i]] = values[i];
      } else {
        result[list[i][0]] = list[i][1];
      }
    }
    return result;
  };

	fns.spotcheck=function(max){
		max=max||10
		this=this.randomize();
		return this.slice(0,max);
	}

	fns.first=function(max){
		max=max||1
		return this.slice(0,max);
	}
  fns.top=fns.first;

	fns.head=function(max){
		max=max||10;
		return fns.first(max)
	}

	//add them to the prototype
	Object.keys(fns).forEach(function(i){
		Object.defineProperty(Array.prototype, i, {
			value: fns[i],
			configurable: true,
		  enumerable: false
		});
	})





String.prototype.isin=function(arr){
	var word=this;
	return arr.some(function(v){return word==v})
}
Number.prototype.isin=function(arr){
	var word=this;
	return arr.some(function(v){return word==v})
}

Number.prototype.to=function(stop, step) {
		var start=this;
    if (stop==null||stop==undefined||stop==start) {
      return []
    }
    step=step||1;
    var arr=[];
    if(stop>start){//go forwards
    	for(var i=start;i<=stop;i+=step){
    		arr.push(i)
    	}
    }else{//go backwards
			for(var i=start;i>=stop;i-=step){
    		arr.push(i)
    	}
    }
    return arr;
  };

// x=3
// x.to(-700).print()
//////////

var fns={};

fns.values=function(){
				var obj=this;
				return Object.keys(this).map(function(v){return obj[v]})
			}
fns.keys=function(){
				return Object.keys(this)
			}
fns.map=function(fn){
				var obj=this;
				return Object.keys(this).map(function(v){
					return fn(obj[v],v)
				})
			}
fns.each=function(fn){
	var obj=this;
	Object.keys(this).map(function(v){
		return fn(obj[v],v)
	})
}
fns.toarr=function(){
				var arr=[]
				for(var i in this){
					arr.push([i, this[i]])
				}
				return arr
			}
fns.size=function(){
    var size = 0, key;
    for (key in this) {
        if(this.hasOwnProperty(key)){size+=1;}
    }
    return size;
	};
fns.filter=function(fn){
		var obj=this;
		var arr= Object.keys(this).filter(function(v){
			return fn(obj[v], v);
		})
		var newobj={}
		arr.forEach(function(a){
			newobj[a]=obj[a]
		});
		return newobj
}
fns.extend=function(obj) {
    for(var i in obj){
    	this[i]=obj[i];
    }
    return obj;
  };

fns.print=function(){
			console.log(JSON.stringify(this, null, 2));
		}
fns.printf=fns.print
fns.log=fns.print

fns.combine=fns.extend;
fns.add=fns.extend;

/*
	fns.grab=function(str){
		  var obj=this;
			return Object.keys(this).map(function(k){
				return obj[str]
			})
		}
	fns.collect=fns.grab;*/


Object.keys(fns).forEach(function(i){
	Object.defineProperty(Object.prototype, i, {
		value: fns[i],
		configurable: true,
	  enumerable: false
	});
})




	//repair the array prototype
	dirty.undo=function(){
		Object.keys(fns).forEach(function(i){
			Object.defineProperty(Array.prototype, i, {
			    value: undefined
			});
		})
	}
	dirty.fix=dirty.undo;
	dirty.clean=dirty.undo;
	dirty.cleanup=dirty.undo;

//export the module
    // AMD / RequireJS
    if (typeof define !== 'undefined' && define.amd) {
        define([], function () {
            return dirty;
        });
    }
    // Node.js
    else if (typeof module !== 'undefined' && module.exports) {
        module.exports = dirty;
    }

    return dirty;

})()


//  r=[3,4,3,4,[5],6,0,null,7]
//   r.flatten().compact().print()

// dirty.undo()
// r={f:3,fe:2,q:99}
// x=r.map(function(s,i){return s})
//x.print()
// console.log(r.size())
// console.log(r.filter(function(v){return v<5}))
// console.log(r.filter(function(v,i){return i=="f"}))
// r.toarr().print()
//   r.print()

//  for(var i in r){
//   console.log(i)
//  }
r=[2,3,4,5]
//r.overlap([3,4,88,8]).print()
//r.spigot(function(v){return v>3}).print()
	 r=[{f:3},{f:2},{f:9}]
	// var d=[1,2,4]

 // r.spigot(function(v){return v.f.isin(d)}).print()
 //r.sum('f').print()
 //r.average('f').print()

// r.percentage(function(s){return s.f>2}).print()


var results=["dan","tom","spencer"]
var wanted=["dan","spencer","john","frank","bill","sam"]
// results.mean_average_precision(wanted).print()
// results.recall(wanted).print()