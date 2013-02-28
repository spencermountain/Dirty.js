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

//nulls or undefined
	fns.uniq=function(){
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


	//add them to the prototype
	Object.keys(fns).forEach(function(i){
		Object.defineProperty(Array.prototype, i, {
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


//   r.print()

//  for(var i in r){
//   console.log(i)
//  }
