(function() {
  var ArgumentError, OperationError, SyntaxError, TypeError, ValueRequiredError;

  exports.ArgumentError = ArgumentError = class ArgumentError extends Error {};

  exports.ValueRequiredError = ValueRequiredError = class ValueRequiredError extends Error {};

  exports.TypeError = TypeError = class TypeError extends Error {};

  exports.OperationError = OperationError = class OperationError extends Error {};

  exports.SyntaxError = SyntaxError = class SyntaxError extends Error {};

}).call(this);
