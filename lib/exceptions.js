(function() {
  var ArgumentError, TypeError, ValueRequiredError,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  exports.ArgumentError = ArgumentError = (function(superClass) {
    extend(ArgumentError, superClass);

    function ArgumentError() {
      return ArgumentError.__super__.constructor.apply(this, arguments);
    }

    return ArgumentError;

  })(Error);

  exports.ValueRequiredError = ValueRequiredError = (function(superClass) {
    extend(ValueRequiredError, superClass);

    function ValueRequiredError() {
      return ValueRequiredError.__super__.constructor.apply(this, arguments);
    }

    return ValueRequiredError;

  })(Error);

  exports.TypeError = TypeError = (function(superClass) {
    extend(TypeError, superClass);

    function TypeError() {
      return TypeError.__super__.constructor.apply(this, arguments);
    }

    return TypeError;

  })(Error);

}).call(this);