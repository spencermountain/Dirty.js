Array.prototype.grab=function(p){
	return this.map(function(s){
		return s[p]
	})
}

 //remove duplicates from array
 Array.prototype.uniq=function(){
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

//pretty-print
 Array.prototype.print=function(){
 	console.log(JSON.stringify(this, null, 2));
 }

//r=[3,4,3,4,5,6]
//console.log(r.print())