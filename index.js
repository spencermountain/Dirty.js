//make a mess

var dirty = (function() {
	var dirty = {};

	var fns = {arr:{}, obj:{}, num:{}, str:{}}

	fns.arr.grab = function(p) {
		//array of fields to return
		if(typeof p=="object" && p.length){
			return this.map(function(s) {
				return p.map(function(f){return s[f]})
			})
		}
		return this.map(function(s) {
			return s[p]
		})
	}
	fns.arr.collect = fns.arr.grab;
	fns.arr.transform = fns.arr.grab;

	fns.arr.clone = function() {
		return JSON.parse(JSON.stringify(this))
	}
	fns.arr.copy = fns.arr.clone;

	//split an array into passes and fails
	fns.arr.spigot = function(fn) {
		var arr = this;
		var all = {
			"true": [],
			"false": []
		}
		arr.forEach(function(v) {
			if (fn(v)) {
				all["true"].push(v)
			} else {
				all["false"].push(v)
			}
		});
		return all;
	}
	fns.arr.moses = fns.arr.spigot;

	fns.arr.max = function(field) {
		if (field) {
			return this.sort(function(a, b) {
				return b[field] - [field]
			})[0]
		}
		return Math.max.apply(null, this)
	}

	//an accuracy score
	fns.arr.mean_average_precision = function(results) {
		if(results.length===0 && this.length===0){return 1}
		var precisions = [];
		var found = 0;
		this.forEach(function(w, i) {
			i++
			if (results.some(function(s){return s==w})) {
			// if (w.isin(results)) {
				found++;
			}
			var precision = found / i;
			precisions.push(precision)
		})
		return precisions.average()
	}



	fns.arr.recall = function(wanted) {
		var results = this;
		if (wanted.length === 0) {
			return 0;
		}
		var overlap = results.overlap(wanted).length;
		return overlap / wanted.length
	}

	fns.arr.precision = function(wanted) {
		var results = this;
		if (results.length === 0) {
			return 0;
		}
		var overlap = results.overlap(wanted).length;
		return overlap / results.length
	}

	//add em up
	fns.arr.sum = function(field) {
		if (field) {
			return this.reduce(function(a, b) {
				return a + b[field];
			}, 0);
		}
		return this.reduce(function(a, b) {
			return a + b;
		}, 0);
	}

	// % of array that pass a test
	fns.arr.percentage = function(fn) {
		var passes = this.filter(fn);
		return parseInt((passes.length / this.length) * 100)
	}

	fns.arr.select=Array.prototype.filter;
	fns.arr.must=fns.arr.select;

	fns.arr.reject = function(filter) {
		if(typeof filter=="function"){
			return this.filter(function(v){return !filter(v)})
		}else if(typeof filter=="number" || typeof filter=="string"){
			return this.filter(function(v){return v!=filter})
		}else if(typeof filter=="object"){
			filter=JSON.stringify(filter)
			return this.filter(function(v){return JSON.stringify(v)!=filter})
		}
	}
	fns.arr.kill = fns.arr.reject
	fns.arr.remove = fns.arr.reject

	fns.arr.average = function(field) {
		if(this.length===0){return 0;}
		var sum = 0
		if (field) {
			sum = this.reduce(function(a, b) {
				return a + b[field];
			}, 0);
		} else {
			sum = this.reduce(function(a, b) {
				return a + b;
			}, 0);
		}
		return sum / this.length
	}
	fns.arr.mean = fns.arr.average;


	fns.arr.strings = function() {
		return this.filter(function(v) {
			return typeof v == "string"
		})
	}

	fns.arr.numbers = function() {
		return this.filter(function(v) {
			return typeof v == "object"
		})
	}

	fns.arr.objects = function() {
		return this.filter(function(v) {
			return typeof v == "object"
		})
	}

	fns.arr.truthy = function() {
		return this.filter(function(v) {
			return v
		})
	}

	fns.arr.duplicates = function(field) {
		var arr = this;
		if (field) {
			arr = arr.grab(field);
		}
		arr = arr.sort();
		var results = [];
		for (var i = 0; i < arr.length - 1; i++) {
			if (arr[i + 1] == arr[i]) {
				results.push(arr[i]);
			}
		}
		return results
	}
	fns.arr.dupes=fns.arr.duplicates;

	fns.arr.overlap = function(arr2) {
		return this.filter(function(v) {
			return arr2.some(function(v2) {
				return v === v2
			})
		})
	}
	fns.arr.intersection = fns.arr.overlap
	fns.arr.isin = fns.arr.overlap
	fns.arr.just = fns.arr.overlap

	//arr minus
	fns.arr.missing_from = function(arr2) {
		return this.filter(function(v) {
			return !arr2.some(function(v2) {
				return v === v2
			})
		})
	}


	fns.arr.has_overlap = function(arr2) {
		return this.some(function(v) {
			return arr2.some(function(v2) {
				return v === v2
			})
		})
	}
	fns.arr.overlaps = fns.arr.has_overlap


	fns.arr.topk = function(verbose) {
		var myArray = this;
		var newArray = [];
		var length = myArray.length || 1
		var freq = {};
		//Count Frequency of Occurances
		var i = myArray.length - 1;
		for (var i; i > -1; i--) {
			var value = myArray[i];
			freq[value] == null ? freq[value] = 1 : freq[value]++;
		}
		//convert to sortable array
		for (var value in freq) {
			newArray.push(value);
		}
		newArray = newArray.sort(function(a, b) {
			return freq[b] - freq[a];
		}).map(function(v) {
			return {
				value: v,
				count: freq[v],
				percentage: ((freq[v] / length) * 100).toFixed(2)
			}
		});
		if (verbose) {
			return newArray
		} else {
			return newArray.map(function(s) {
				return s.value
			})
		}
	}
	fns.arr.freq = fns.arr.topk
	fns.arr.frequency = fns.arr.topk

	fns.arr.each = function(fn) {
		this.forEach(fn)
	}
	fns.arr.loop = fns.arr.each;

	//nulls or undefined
	fns.arr.uniq = function(field) {
		var x = this;
		if (!field) {
			var newArray = new Array();
			label: for (var i = 0; i < x.length; i++) {
				for (var j = 0; j < newArray.length; j++) {
					if (newArray[j] == x[i]) continue label;
				}
				newArray[newArray.length] = x[i];
			}
			return newArray;
		} else {
			var newArray = new Array();
			label: for (var i = 0; i < x.length; i++) {
				for (var j = 0; j < newArray.length; j++) {
					if (newArray[j][field] == x[i][field]) continue label;
				}
				newArray[newArray.length] = x[i];
			}
			return newArray;
		}
	}
	fns.arr.unique = fns.arr.uniq
	fns.arr.uniq_by = fns.arr.uniq
	fns.arr.unique_by = fns.arr.uniq

	//remove nulls
	fns.arr.compact = function() {
		return this.filter(function(v) {
			return v === 0 || v
		})
	}

	//remove nested arrays one step
	fns.arr.flatten = function() {
		return this.reduce(function(a, b) {
		    return a.concat(b);
		},[]);
	}

	//pretty-print
	fns.arr.print = function() {
		console.log(JSON.stringify(this, null, 2));
	}
	fns.arr.printf = fns.arr.print
	fns.arr.console = fns.arr.print
	fns.arr.log = fns.arr.print


	fns.arr.shuffle = function() {
		return this.sort(function(a, b) {
			return (Math.round(Math.random()) - 0.5);
		})
	}
	fns.arr.randomize = fns.arr.shuffle;


	fns.arr.group_by = function(str) {
		var obj = {}
		this.forEach(function(t) {
			if (!obj[t[str]]) {
				obj[t[str]] = [t]
			} else {
				obj[t[str]].push(t)
			}
		})
		return obj
	}


	fns.arr.chunk_by = function(group_length) {
		var all = []
		var arr = this;
		group_length = group_length || 1;
		for (var i in arr) {
			if (i % group_length == 0) {
				all.push([arr[i]])
			} else {
				all[all.length - 1].push(arr[i])
			}
		}
		return all
	}


	fns.arr.toobject = function(values) {
		var list = this;
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

	fns.arr.spotcheck = function(max) {
		max = max || 10
		this = this.randomize();
		return this.slice(0, max);
	}

	fns.arr.first = function(filt) {
		filt = filt || 1
		if(typeof filt=="function"){
			var match;
			this.some(function(v){
				if(filt(v)){
					match=v
					return true
				}else{
					return false
				}
			})
			return match;
		}else	if(typeof filt=="number"){
		  return this.slice(0, filt);
		}
	}
	fns.arr.top = fns.arr.first;

	fns.arr.last=function(){
		return this[this.length-1]
	}

	fns.arr.head = function(max) {
		max = max || 10;
		return fns.arr.first(max)
	}


	//////////
	fns.obj.values = function() {
		var obj = this;
		return Object.keys(this).map(function(v) {
			return obj[v]
		})
	}
	fns.obj.keys = function() {
		return Object.keys(this)
	}
	fns.obj.map = function(fn) {
		var obj = this;
		return Object.keys(this).map(function(v) {
			return fn(obj[v], v)
		})
	}
	fns.obj.each = function(fn) {
		var obj = this;
		Object.keys(this).map(function(v) {
			return fn(obj[v], v)
		})
	}
	fns.obj.toarr = function() {
		var arr = []
		for (var i in this) {
			arr.push([i, this[i]])
		}
		return arr
	}
	fns.obj.to_arr=fns.obj.toarr
	fns.obj.to_a=fns.obj.toarr

	fns.obj.size = function() {
		var size = 0,
			key;
		for (key in this) {
			if (this.hasOwnProperty(key)) {
				size += 1;
			}
		}
		return size;
	};
	fns.obj.filter = function(fn) {
		var obj = this;
		var arr = Object.keys(this).filter(function(v) {
			return fn(obj[v], v);
		})
		var newobj = {}
		arr.forEach(function(a) {
			newobj[a] = obj[a]
		});
		return newobj
	}
	fns.obj.extend = function(obj) {
		for (var i in obj) {
			this[i] = obj[i];
		}
		return obj;
	};
	fns.obj.combine = fns.obj.extend;
	fns.obj.add = fns.obj.extend;

	fns.obj.print = function() {
		console.log(JSON.stringify(this, null, 2));
	}
	fns.obj.printf = fns.obj.print
	fns.obj.log = fns.obj.print


	/*
	fns.obj.grab=function(str){
		  var obj=this;
			return Object.keys(this).map(function(k){
				return obj[str]
			})
		}
	fns.obj.collect=fns.obj.grab;*/



fns.str.isin=function(arr) {
		var word = this;
		return arr.some(function(v) {
			return word == v
		})
	}

fns.num.to=function(stop, step) {
		var start = this;
		if (stop == null || stop == undefined || stop == start) {
			return []
		}
		step = step || 1;
		var arr = [];
		if (stop > start) { //go forwards
			for (var i = start; i <= stop; i += step) {
				arr.push(i)
			}
		} else { //go backwards
			for (var i = start; i >= stop; i -= step) {
				arr.push(i)
			}
		}
		return arr;
	};
fns.num.upto=fns.num.to

///////
//add them to the prototype
////////


//write object ones
	Object.keys(fns.obj).forEach(function(i) {
		Object.defineProperty(Object.prototype, i, {
			value: fns.obj[i],
			configurable: true,
			enumerable: false
		});
	})

//write array ones
	Object.keys(fns.arr).forEach(function(i) {
		Object.defineProperty(Array.prototype, i, {
			value: fns.arr[i],
			configurable: true,
			enumerable: false
		});
	})

//write string ones
	Object.keys(fns.str).forEach(function(i) {
		Object.defineProperty(String.prototype, i, {
			value: fns.str[i],
			configurable: true,
			enumerable: false
		});
	})

	//write number ones
	Object.keys(fns.num).forEach(function(i) {
		Object.defineProperty(Number.prototype, i, {
			value: fns.num[i],
			configurable: true,
			enumerable: false
		});
	})


	//repair the prototype
	dirty.undo = function() {
		Object.keys(fns).forEach(function(i) {
			Object.defineProperty(Array.prototype, i, {
				value: undefined
			});
		})
	}
	dirty.fix = dirty.undo;
	dirty.clean = dirty.undo;
	dirty.cleanup = dirty.undo;

	//export the module
	// AMD / RequireJS
	if (typeof define !== 'undefined' && define.amd) {
		define([], function() {
			return dirty;
		});
	}
	// Node.js
	else if (typeof module !== 'undefined' && module.exports) {
		module.exports = dirty;
	}




	function documentation(){
		var arr=[];
		arr.push('##Object methods')
		Object.keys(fns.obj).forEach(function(v){
			arr.push('* __.'+v+'__ ( ) ')
		})
		arr.push('')
		arr.push('##Array methods')
		Object.keys(fns.arr).forEach(function(v){
			arr.push('* __.'+v+'__ ( )')
		})
		arr.push('')
		arr.push('##Number methods')
		Object.keys(fns.num).forEach(function(v){
			arr.push('* __x.'+v+'__ ( )')
		})
		arr.push('')
		arr.push('##String methods')
		Object.keys(fns.str).forEach(function(v){
			arr.push('* __str.'+v+'__ ( )')
		})
		return arr.join('\n')
	}
//console.log(documentation())

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
//r=[2,3,4,5]
//r.overlap([3,4,88,8]).print()
//r.spigot(function(v){return v>3}).print()
//	 r=[{f:3},{f:2},{f:9}]
// var d=[1,2,4]

// r.spigot(function(v){return v.f.isin(d)}).print()
//r.sum('f').print()
//r.average('f').print()

// r.percentage(function(s){return s.f>2}).print()


// var results=["dan","tom","spencer",null]
// var wanted=["dan","spencer","john",null,"frank","bill","sam"]
//  results.mean_average_precision(wanted).print()
// // results.recall(wanted).print()

//arr=[1,2,3,3,null,[3],2]
     // arr.uniq().flatten().sum().upto(10).print()
