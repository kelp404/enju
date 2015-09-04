(function() {
  var ArgumentError,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  exports.ArgumentError = ArgumentError = (function(superClass) {
    extend(ArgumentError, superClass);

    function ArgumentError() {
      return ArgumentError.__super__.constructor.apply(this, arguments);
    }

    return ArgumentError;

  })(Error);

}).call(this);
