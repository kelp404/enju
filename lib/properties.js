(function() {
  var BooleanProperty, DateProperty, FloatProperty, IntegerProperty, ListProperty, ObjectProperty, Property, ReferenceProperty, StringProperty, exceptions, util,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  util = require('util');

  exceptions = require('./exceptions');

  Property = (function() {

    /*
    @property default {bool}
    @property required {bool}
    @property dbField {string}
    @property type {string}  For elasticsearch mapping
    @property index {string}  For elasticsearch mapping
    @property analyzer {string}  For elasticsearch mapping
    @property mapping {object}  For elasticsearch mapping
    @property propertyName {string} The property name in the document. It will be set at Document.define()
     */
    function Property(args) {
      if (args == null) {
        args = {};
      }
      this["default"] = args["default"], this.required = args.required, this.dbField = args.dbField, this.type = args.type, this.index = args.index, this.analyzer = args.analyzer, this.mapping = args.mapping;
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

    IntegerProperty.prototype.toJs = function(value) {
      if (value == null) {
        if (this["default"] != null) {
          return parseInt(this["default"]);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      return parseInt(value);
    };

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

    FloatProperty.prototype.toJs = function(value) {
      if (value == null) {
        if (this["default"] != null) {
          return parseFloat(this["default"]);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      return parseFloat(value);
    };

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

    BooleanProperty.prototype.toJs = function(value) {
      if (value == null) {
        if (this["default"] != null) {
          return Boolean(this["default"]);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      return Boolean(value);
    };

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

    DateProperty.prototype.toJs = function(value) {
      if (value == null) {
        if (this.autoNow) {
          return new Date();
        } else if (this["default"] != null) {
          return new Date(this["default"]);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      return new Date(value);
    };

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

    ListProperty.prototype.toJs = function(value) {
      var x;
      if (value == null) {
        if (this["default"] != null) {
          return Array.apply(this, this["default"]);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      if (this.itemClass != null) {
        switch (this.itemClass) {
          case StringProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? x.toString() : null);
              }
              return results;
            })();
            break;
          case IntegerProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? parseInt(x) : null);
              }
              return results;
            })();
            break;
          case FloatProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? parseFloat(x) : null);
              }
              return results;
            })();
            break;
          case BooleanProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? Boolean(x) : null);
              }
              return results;
            })();
            break;
          case DateProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? x.toJSON() : null);
              }
              return results;
            })();
            break;
          case ListProperty:
          case ObjectProperty:
          case ReferenceProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? x : null);
              }
              return results;
            })();
            break;
          default:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? new this.itemClass(x) : null);
              }
              return results;
            }).call(this);
        }
      }
      return value;
    };

    ListProperty.prototype.toDb = function(classInstance) {
      var value, x;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = Array.apply(this, this["default"]);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(classInstance.constructor.name + "." + this.propertyName + " is required.");
        }
        return null;
      }
      if (this.itemClass != null) {
        switch (this.itemClass) {
          case StringProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? x.toString() : null);
              }
              return results;
            })();
            break;
          case IntegerProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? parseInt(x) : null);
              }
              return results;
            })();
            break;
          case FloatProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? parseFloat(x) : null);
              }
              return results;
            })();
            break;
          case BooleanProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? Boolean(x) : null);
              }
              return results;
            })();
            break;
          case DateProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? x.toJSON() : null);
              }
              return results;
            })();
            break;
          case ListProperty:
          case ObjectProperty:
          case ReferenceProperty:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? x : null);
              }
              return results;
            })();
            break;
          default:
            value = (function() {
              var i, len, results;
              results = [];
              for (i = 0, len = value.length; i < len; i++) {
                x = value[i];
                results.push(x != null ? new this.itemClass(x) : null);
              }
              return results;
            }).call(this);
        }
      }
      return value;
    };

    return ListProperty;

  })(Property);

  exports.ListProperty = ListProperty;

  ObjectProperty = (function(superClass) {
    extend(ObjectProperty, superClass);

    function ObjectProperty(args) {
      ObjectProperty.__super__.constructor.call(this, args);
    }

    ObjectProperty.prototype.toJs = function(value) {
      if (value == null) {
        if (this["default"] != null) {
          return util._extend({}, this["default"]);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      return value;
    };

    ObjectProperty.prototype.toDb = function(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this["default"] != null) {
          classInstance[this.propertyName] = util._extend({}, this["default"]);
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

    ReferenceProperty.prototype.toJs = function(value) {
      if (value == null) {
        if (this["default"] != null) {
          return this["default"];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(this.propertyName + " is required.");
        }
        return null;
      }
      if (typeof value === 'string') {
        return value;
      } else if (typeof value === 'object' && value.constructor === this.referenceClass) {
        return value;
      } else {
        throw new exceptions.TypeError(this.propertyName + " has wrong type.");
      }
    };

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
