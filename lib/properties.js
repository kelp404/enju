(function() {
  var BooleanProperty, DateProperty, FloatProperty, IntegerProperty, KeywordProperty, ListProperty, ObjectProperty, Property, ReferenceProperty, StringProperty, TextProperty, exceptions, util;

  util = require('util');

  exceptions = require('./exceptions');

  Property = class Property {
    /*
    @property default {any}
    @property required {bool}
    @property dbField {string}
    @property type {string}  https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping-types.html
    @property index {bool}  https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping-index.html
    @property mapping {object}  https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping.html
    @property propertyName {string} The property name in the document. It will be set at Document.define()
    */
    constructor(args = {}) {
      ({required: this.required, dbField: this.dbField, type: this.type, index: this.index, mapping: this.mapping} = args);
      this.defaultValue = args.default;
      if (this.required == null) {
        this.required = false;
      }
      if (this.index == null) {
        this.index = true;
      }
    }

  };

  StringProperty = class StringProperty extends Property {
    constructor(args = {}) {
      super(args);
      // analyzer: https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analyzer.html
      ({analyzer: this.analyzer} = args);
    }

    toJs(value) {
      /*
      Convert value for initial Document.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
      */
      if (value == null) {
        if (this.defaultValue != null) {
          return this.defaultValue.toString();
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return value.toString();
    }

    toDb(classInstance) {
      /*
      Convert value for writing database.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
      */
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = this.defaultValue.toString();
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return value.toString();
    }

  };

  exports.StringProperty = StringProperty;

  TextProperty = class TextProperty extends Property {
    constructor(args = {}) {
      super(args);
      // analyzer: https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analyzer.html
      ({analyzer: this.analyzer} = args);
    }

    toJs(value) {
      /*
      Convert value for initial Document.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
      */
      if (value == null) {
        if (this.defaultValue != null) {
          return this.defaultValue.toString();
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return value.toString();
    }

    toDb(classInstance) {
      /*
      Convert value for writing database.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
      */
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = this.defaultValue.toString();
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return value.toString();
    }

  };

  exports.TextProperty = TextProperty;

  KeywordProperty = class KeywordProperty extends Property {
    constructor(args = {}) {
      super(args);
      // normalizer: https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analysis-normalizers.html
      ({normalizer: this.normalizer} = args);
    }

    toJs(value) {
      /*
      Convert value for initial Document.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
      */
      if (value == null) {
        if (this.defaultValue != null) {
          return this.defaultValue.toString();
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return value.toString();
    }

    toDb(classInstance) {
      /*
      Convert value for writing database.
      @param classInstance: {Document} The instance of the document.
      @returns {string}
      */
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = this.defaultValue.toString();
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return value.toString();
    }

  };

  exports.KeywordProperty = KeywordProperty;

  IntegerProperty = class IntegerProperty extends Property {
    constructor(args) {
      super(args);
    }

    toJs(value) {
      if (value == null) {
        if (this.defaultValue != null) {
          return parseInt(this.defaultValue);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return parseInt(value);
    }

    toDb(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = parseInt(this.defaultValue);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return parseInt(value);
    }

  };

  exports.IntegerProperty = IntegerProperty;

  FloatProperty = class FloatProperty extends Property {
    constructor(args) {
      super(args);
    }

    toJs(value) {
      if (value == null) {
        if (this.defaultValue != null) {
          return parseFloat(this.defaultValue);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return parseFloat(value);
    }

    toDb(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = parseFloat(this.defaultValue);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return parseFloat(value);
    }

  };

  exports.FloatProperty = FloatProperty;

  BooleanProperty = class BooleanProperty extends Property {
    constructor(args) {
      super(args);
    }

    toJs(value) {
      if (value == null) {
        if (this.defaultValue != null) {
          return Boolean(this.defaultValue);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return Boolean(value);
    }

    toDb(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = Boolean(this.defaultValue);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return Boolean(value);
    }

  };

  exports.BooleanProperty = BooleanProperty;

  DateProperty = class DateProperty extends Property {
    constructor(args = {}) {
      super(args);
      ({autoNow: this.autoNow} = args);
    }

    toJs(value) {
      if (value == null) {
        if (this.autoNow) {
          return new Date();
        } else if (this.defaultValue != null) {
          return new Date(this.defaultValue);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return new Date(value);
    }

    toDb(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.autoNow) {
          classInstance[this.propertyName] = new Date();
          return classInstance[this.propertyName].toJSON();
        } else if (this.defaultValue != null) {
          classInstance[this.propertyName] = new Date(this.defaultValue);
          return classInstance[this.propertyName].toJSON();
        } else {
          if (this.required) {
            throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
          }
        }
        return null;
      }
      return value.toJSON();
    }

  };

  exports.DateProperty = DateProperty;

  ListProperty = class ListProperty extends Property {
    constructor(args = {}) {
      super(args);
      ({itemClass: this.itemClass} = args);
    }

    toJs(value) {
      var x;
      if (value == null) {
        if (this.defaultValue != null) {
          return Array.apply(this, this.defaultValue);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      if (this.itemClass != null) {
        switch (this.itemClass) {
          case StringProperty:
          case TextProperty:
          case KeywordProperty:
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
                results.push(x != null ? new Date(x) : null);
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
    }

    toDb(classInstance) {
      var value, x;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = Array.apply(this, this.defaultValue);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      if (this.itemClass != null) {
        switch (this.itemClass) {
          case StringProperty:
          case TextProperty:
          case KeywordProperty:
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
    }

  };

  exports.ListProperty = ListProperty;

  ObjectProperty = class ObjectProperty extends Property {
    constructor(args) {
      super(args);
    }

    toJs(value) {
      if (value == null) {
        if (this.defaultValue != null) {
          return util._extend({}, this.defaultValue);
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      return value;
    }

    toDb(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = util._extend({}, this.defaultValue);
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      return value;
    }

  };

  exports.ObjectProperty = ObjectProperty;

  ReferenceProperty = class ReferenceProperty extends Property {
    constructor(args = {}) {
      super(args);
      ({referenceClass: this.referenceClass} = args);
    }

    toJs(value) {
      if (value == null) {
        if (this.defaultValue != null) {
          return this.defaultValue;
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${this.propertyName} is required.`);
        }
        return null;
      }
      if (typeof value === 'string') {
        return value;
      } else if (typeof value === 'object' && value.constructor === this.referenceClass) {
        return value;
      } else {
        throw new exceptions.TypeError(`${this.propertyName} has wrong type.`);
      }
    }

    toDb(classInstance) {
      var value;
      value = classInstance[this.propertyName];
      if (value == null) {
        if (this.defaultValue != null) {
          classInstance[this.propertyName] = this.defaultValue;
          return classInstance[this.propertyName];
        }
        if (this.required) {
          throw new exceptions.ValueRequiredError(`${classInstance.constructor.name}.${this.propertyName} is required.`);
        }
        return null;
      }
      if (typeof value === 'string') {
        return value;
      } else if (typeof value === 'object' && value.constructor === this.referenceClass) {
        return value.id;
      } else {
        throw new exceptions.TypeError(`${classInstance.constructor.name}.${this.propertyName} has wrong type.`);
      }
    }

  };

  exports.ReferenceProperty = ReferenceProperty;

}).call(this);
