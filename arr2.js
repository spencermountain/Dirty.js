// Generated by CoffeeScript 1.6.3
var arr;

arr = (function() {
  var alias, blurb, objarr, simplearr, test;
  arr = {};
  alias = {};
  blurb = {};
  test = {};
  arr.grab = {
    fn: function(p) {
      if (typeof p === "object" && p.length) {
        return this.map(function(s) {
          return p.map(function(f) {
            return s[f];
          });
        });
      }
      return this.map(function(s) {
        return s[p];
      });
    },
    alias: ['collect', 'transform', 'pluck'],
    test: [null, ['a', [4, 9, null]]]
  };
  Object.keys(arr).forEach(function(i) {
    return Object.defineProperty(Array.prototype, i, {
      value: arr[i].fn,
      configurable: true,
      enumerable: false
    });
  });
  simplearr = [1, 2, 3, 5, 3, 4];
  return objarr = [
    {
      a: 4,
      b: 2
    }, {
      a: 9
    }, {
      b: 8
    }
  ];
})();
