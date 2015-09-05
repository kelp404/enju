(function() {
  var BooleanProperty, DateProperty, FloatProperty, IntegerProperty, ListProperty, ObjectProperty, Property, ReferenceProperty, StringProperty, exceptions,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  exceptions = require('./exceptions');

  Property = (function() {

    /*
    @property default: {bool}
    @property required: {bool}
    @property dbField: {string}
    @property analyzer: {string}
    @property mapping: {object}
    @property propertyName: {string} The property name. It will be set at Document.define()
     */
    function Property(args) {
      if (args == null) {
        args = {};
      }
      this["default"] = args["default"], this.required = args.required, this.dbField = args.dbField, this.analyzer = args.analyzer, this.mapping = args.mapping;
      if (this.required == null) {
        this.required = false;
      }
    }

    return Property;

  })();

  StringProperty = (function(superClass) {
    extend(StringProperty, superClass);

    function StringProperty(args) {
      StringProperty.__super__.constructor.call(this, args);
    }

    StringProperty.prototype.toJs = function(value) {

      /*
      Convert value for initial Document.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
       */
      if (value == null) {
        if (this["default"] != null) {
          return this["default"].toString();
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      return value.toString();
    };

    StringProperty.prototype.toDb = function(classInstance) {

      /*
      Convert value for writing database.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
       */
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = this["default"].toString();
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      return value.toString();
    };

    return StringProperty;

  })(Property);

  exports.StringProperty = StringProperty;

  IntegerProperty = (function(superClass) {
    extend(IntegerProperty, superClass);

    function IntegerProperty(args) {
      IntegerProperty.__super__.constructor.call(this, args);
    }

    IntegerProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = parseInt(this["default"]);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      return parseInt(value);
    };

    return IntegerProperty;

  })(Property);

  exports.IntegerProperty = IntegerProperty;

  FloatProperty = (function(superClass) {
    extend(FloatProperty, superClass);

    function FloatProperty(args) {
      FloatProperty.__super__.constructor.call(this, args);
    }

    FloatProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = parseFloat(this["default"]);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      return parseFloat(value);
    };

    return FloatProperty;

  })(Property);

  exports.FloatProperty = FloatProperty;

  BooleanProperty = (function(superClass) {
    extend(BooleanProperty, superClass);

    function BooleanProperty(args) {
      BooleanProperty.__super__.constructor.call(this, args);
    }

    BooleanProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = Boolean(this["default"]);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      return Boolean(value);
    };

    return BooleanProperty;

  })(Property);

  exports.BooleanProperty = BooleanProperty;

  DateProperty = (function(superClass) {
    extend(DateProperty, superClass);

    function DateProperty(args) {
      if (args == null) {
        args = {};
      }
      this.autoNow = args.autoNow;
      DateProperty.__super__.constructor.call(this, args);
    }

    DateProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.autoNow) {
          classInstance[this.propertyName] = new Date();
          return classInstance[this.propertyName].toJSON();
        } else if (this["default"] != null) {
          classInstance[this.propertyName] = new Date(this["default"]);
          return classInstance[this.propertyName].toJSON();
        } else {
          if (this.required) {
            throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
          }
        }
        return null;
      }
      return value.toJSON();
    };

    return DateProperty;

  })(Property);

  exports.DateProperty = DateProperty;

  ListProperty = (function(superClass) {
    extend(ListProperty, superClass);

    function ListProperty(args) {
      if (args == null) {
        args = {};
      }
      this.itemClass = args.itemClass;
      ListProperty.__super__.constructor.call(this, args);
    }

    ListProperty.prototype.toDb = function(classInstance) {
      var value, x;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = this["default"];
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      if (this.itemClass != null) {
        switch (itemClass) {
          case StringProperty:
            value = [
              (function() {
                var i, len, results;
                if (typeof x !== "undefined" && x !== null) {
                  return x.toString();
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
            break;
          case IntegerProperty:
            value = [
              (function() {
                var i, len, results;
                if (x != null) {
                  return parseInt(x);
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
            break;
          case FloatProperty:
            value = [
              (function() {
                var i, len, results;
                if (x != null) {
                  return parseFloat(x);
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
            break;
          case BooleanProperty:
            value = [
              (function() {
                var i, len, results;
                if (x != null) {
                  return Boolean(x);
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
            break;
          case DateProperty:
            value = [
              (function() {
                var i, len, results;
                if (x != null) {
                  return x.toJSON();
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
            break;
          case ListProperty:
          case ObjectProperty:
          case ReferenceProperty:
            value = [
              (function() {
                var i, len, results;
                if (x != null) {
                  return x;
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
            break;
          default:
            value = [
              (function() {
                var i, len, results;
                if (x != null) {
                  return new itemClass(x);
                } else {
                  results = [];
                  for (i = 0, len = value.length; i < len; i++) {
                    x = value[i];
                    results.push(null);
                  }
                  return results;
                }
              })()
            ];
        }
        return value;
      } else {
        return value;
      }
    };

    return ListProperty;

  })(Property);

  exports.ListProperty = ListProperty;

  ObjectProperty = (function(superClass) {
    extend(ObjectProperty, superClass);

    function ObjectProperty(args) {
      ObjectProperty.__super__.constructor.call(this, args);
    }

    ObjectProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = this["default"];
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      return value;
    };

    return ObjectProperty;

  })(Property);

  exports.ObjectProperty = ObjectProperty;

  ReferenceProperty = (function(superClass) {
    extend(ReferenceProperty, superClass);

    function ReferenceProperty(args) {
      if (args == null) {
        args = {};
      }
      this.referenceClass = args.referenceClass;
      ReferenceProperty.__super__.constructor.call(this, args);
    }

    ReferenceProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = this["default"];
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      if (typeof value === 'string') {
        return value;
      } else if (typeof value === 'object' && value.constructor === this.referenceClass) {
        return value.id;
      } else {
        throw new exceptions.TypeError(classInstance.constructor.name + "." + this.propertyName + " has wrong type.");
      }
    };

    return ReferenceProperty;

  })(Property);

  exports.ReferenceProperty = ReferenceProperty;

}).call(this);
