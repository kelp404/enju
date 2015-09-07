(function() {
  var exceptions, properties;

  exports.Document = require('./lib/document');

  properties = require('./lib/properties');

  exports.StringProperty = properties.StringProperty;

  exports.IntegerProperty = properties.IntegerProperty;

  exports.FloatProperty = properties.FloatProperty;

  exports.BooleanProperty = properties.BooleanProperty;

  exports.DateProperty = properties.DateProperty;

  exports.ListProperty = properties.ListProperty;

  exports.ObjectProperty = properties.ObjectProperty;

  exports.ReferenceProperty = properties.ReferenceProperty;

  exceptions = require('./lib/exceptions');

  exports.ArgumentError = exceptions.ArgumentError;

  exports.ValueRequiredError = exceptions.ValueRequiredError;

  exports.TypeError = exceptions.TypeError;

  exports.OperationError = exceptions.OperationError;

  exports.SyntaxError = exceptions.SyntaxError;

}).call(this);
