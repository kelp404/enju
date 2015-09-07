(function() {
  var Document, Query, config, exceptions, properties, q, utils,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  config = require('config');

  q = require('q');

  utils = require('./utils');

  Query = require('./query');

  properties = require('./properties');

  exceptions = require('./exceptions');

  module.exports = Document = (function() {

    /*
    @property _index: {string} You can set index name by this attribute.
    @property _type: {string} You can set type of the document. The default is class name.
    @property _settings: {object} You can set index settings by this attribute.
    @property id: {string}
    @property version: {number}
    @property _properties: {object} {'propertyName': {Property}}
    @property _es: {Elasticsearch.Client}
     */
    Document._properties = {
      id: new properties.StringProperty({
        dbField: '_id'
      }),
      version: new properties.IntegerProperty({
        dbField: '_version'
      })
    };

    Document._es = utils.getElasticsearch();

    function Document(args) {
      var property, propertyName, ref;
      if (args == null) {
        args = {};
      }
      ref = this.constructor._properties;
      for (propertyName in ref) {
        property = ref[propertyName];
        this[propertyName] = property.toJs(args[propertyName]);
      }
    }

    Document.getIndexName = function() {

      /*
      Get the index name with prefix.
      @returns: {string}
       */
      return "" + (utils.getIndexPrefix()) + this._index;
    };

    Document.getDocumentType = function() {

      /*
      Get the document type.
      @returns {string}
       */
      var ref;
      return (ref = this._type) != null ? ref : this.name;
    };

    Document.define = function() {

      /*
      1. define properties with class name.
          @param className: {string}
          @param properties: {object}
          @returns {constructor}
      2. define properties for this document.
          @param properties: {object}
       */
      var DynamicClass, defined, property, propertyName;
      if (arguments.length === 2 && typeof arguments[0] === 'string' && typeof arguments[1] === 'object') {
        defined = arguments[1];
        if (defined._type == null) {
          defined._type = arguments[0];
        }
        DynamicClass = (function(superClass) {
          extend(DynamicClass, superClass);

          function DynamicClass() {
            return DynamicClass.__super__.constructor.apply(this, arguments);
          }

          DynamicClass.define(defined);

          return DynamicClass;

        })(this);
        return DynamicClass;
      } else if (arguments.length === 1 && typeof arguments[0] === 'object') {
        defined = arguments[0];
        if ('_index' in defined) {
          this._index = defined._index;
          delete defined._index;
        }
        if ('_settings' in defined) {
          this._settings = defined._settings;
          delete defined._settings;
        }
        if ('_type' in defined) {
          this._type = defined._type;
          delete defined._type;
        }
        for (propertyName in defined) {
          property = defined[propertyName];
          property.propertyName = propertyName;
          this._properties[propertyName] = property;
        }
        return;
      }
      throw exceptions.ArgumentError('Argument error for enju.Document.define()');
    };

    Document.get = function(ids, fetchReference) {
      var deferred, x;
      if (fetchReference == null) {
        fetchReference = true;
      }

      /*
      Fetch the document with id or ids.
      If the document is not exist, it will return null.
      @param ids: {string|list}
      @param fetchReference: {bool} Fetch reference data of this document.
      @returns {promise} (Document|null|list)
       */
      deferred = q.defer();
      if ((ids == null) || ids === '') {
        deferred.resolve(null);
        return deferred.promise;
      }
      if (ids.constructor === Array) {
        ids = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = ids.length; i < len; i++) {
            x = ids[i];
            if (x) {
              results.push(x);
            }
          }
          return results;
        })();
        if (ids.length === 0) {
          deferred.resolve([]);
          return deferred.promise;
        }
      }
      if (ids.constructor === Array) {
        this._es.mget({
          index: this.getIndexName(),
          type: this.getDocumentType(),
          body: {
            ids: ids
          }
        }, (function(_this) {
          return function(error, response) {
            var dbField, doc, i, item, len, property, propertyName, ref, ref1, ref2, result;
            if (error) {
              deferred.reject(error);
              return;
            }
            result = [];
            ref = response.docs;
            for (i = 0, len = ref.length; i < len; i++) {
              doc = ref[i];
              item = {
                id: doc._id,
                version: doc._version
              };
              ref1 = _this._properties;
              for (propertyName in ref1) {
                property = ref1[propertyName];
                dbField = (ref2 = property.dbField) != null ? ref2 : propertyName;
                if (dbField in doc._source) {
                  item[propertyName] = doc._source[dbField];
                }
              }
              result.push(new _this(item));
            }
            return deferred.resolve(result);
          };
        })(this));
        return deferred.promise;
      }
      this._es.get({
        index: this.getIndexName(),
        type: this.getDocumentType(),
        id: ids
      }, (function(_this) {
        return function(error, response) {
          var args;
          if (error) {
            if (error.status === '404') {
              deferred.resolve(null);
              return;
            }
            deferred.reject(error);
            return;
          }
          args = response._source;
          args.id = response._id;
          args.version = response._version;
          return deferred.resolve(new _this(args));
        };
      })(this));
      return deferred.promise;
    };

    Document.all = function() {

      /*
      Generate a query for this document.
      @returns {Query}
       */
      return new Query(this);
    };

    Document.where = function(field, operation) {

      /*
      Generate the query for this document.
      Please via Query.intersect().
       */
      var query;
      query = new Query(this);
      return query.intersect(field, operation);
    };

    Document.updateMapping = function() {

      /*
      Update the index mapping.
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
      @returns {promise}
       */
      var closeIndex, createIndex, deferred, openIndex, putMapping, putSettings;
      createIndex = (function(_this) {
        return function() {
          var deferred;
          deferred = q.defer();
          _this._es.indices.create({
            index: _this.getIndexName()
          }, function(error, response) {
            if (error && error.status !== '400') {
              deferred.reject(error);
              return;
            }
            return setTimeout(function() {
              return deferred.resolve(response);
            }, 1000);
          });
          return deferred.promise;
        };
      })(this);
      closeIndex = (function(_this) {
        return function() {
          var deferred;
          deferred = q.defer();
          _this._es.indices.close({
            index: _this.getIndexName()
          }, function(error, response) {
            if (error) {
              deferred.reject(error);
              return;
            }
            return deferred.resolve(response);
          });
          return deferred.promise;
        };
      })(this);
      putSettings = (function(_this) {
        return function() {
          var deferred;
          deferred = q.defer();
          if (!_this._settings) {
            deferred.resolve();
            return deferred.promise;
          }
          _this._es.indices.putSettings({
            index: _this.getIndexName(),
            body: {
              settings: {
                index: _this._settings
              }
            }
          }, function(error, response) {
            if (error) {
              deferred.reject(error);
              return;
            }
            return deferred.resolve(response);
          });
          return deferred.promise;
        };
      })(this);
      putMapping = (function(_this) {
        return function() {
          var deferred, field, mapping, property, propertyName, ref, ref1, ref2;
          deferred = q.defer();
          mapping = {};
          ref = _this._properties;
          for (propertyName in ref) {
            property = ref[propertyName];
            if ((ref1 = property.dbField) === '_id' || ref1 === '_version') {
              continue;
            }
            if (property.mapping) {
              mapping[propertyName] = {
                properties: property.mapping
              };
              continue;
            }
            field = {};
            switch (property.constructor) {
              case properties.StringProperty:
                field['type'] = 'string';
                break;
              case properties.BooleanProperty:
                field['type'] = 'boolean';
                break;
              case properties.IntegerProperty:
                field['type'] = 'long';
                break;
              case properties.FloatProperty:
                field['type'] = 'double';
                break;
              case properties.DateProperty:
                field['type'] = 'date';
                field['format'] = 'dateOptionalTime';
                break;
              case properties.ReferenceProperty:
                field['type'] = 'string';
                field['analyzer'] = 'keyword';
                break;
              case properties.ListProperty:
                switch (property.itemClass) {
                  case properties.StringProperty:
                    field['type'] = 'string';
                    break;
                  case properties.BooleanProperty:
                    field['type'] = 'boolean';
                    break;
                  case properties.IntegerProperty:
                    field['type'] = 'long';
                    break;
                  case properties.FloatProperty:
                    field['type'] = 'double';
                    break;
                  case properties.DateProperty:
                    field['type'] = 'date';
                    field['format'] = 'dateOptionalTime';
                    break;
                  case properties.ReferenceProperty:
                    field['type'] = 'string';
                    field['analyzer'] = 'keyword';
                }
            }
            if (property.analyzer) {
              field['analyzer'] = property.analyzer;
            }
            if (Object.keys(field).length) {
              mapping[(ref2 = property.dbField) != null ? ref2 : propertyName] = field;
            }
          }
          _this._es.indices.putMapping({
            index: _this.getIndexName(),
            type: _this.getDocumentType(),
            body: {
              properties: mapping
            }
          }, function(error, response) {
            if (error) {
              deferred.reject(error);
              return;
            }
            return deferred.resolve(response);
          });
          return deferred.promise;
        };
      })(this);
      openIndex = (function(_this) {
        return function() {
          var deferred;
          deferred = q.defer();
          _this._es.indices.open({
            index: _this.getIndexName()
          }, function(error, response) {
            if (error) {
              deferred.reject(error);
              return;
            }
            return deferred.resolve(response);
          });
          return deferred.promise;
        };
      })(this);
      deferred = q.defer();
      createIndex().then(closeIndex).then(putSettings).then(putMapping).then(openIndex).then((function(_this) {
        return function() {
          console.log("updated mapping [" + (_this.getIndexName()) + "]");
          return deferred.resolve();
        };
      })(this), function(error) {
        console.error(error);
        return deferred.reject(error);
      });
      return deferred.promise;
    };

    Document.prototype.save = function(refresh) {
      var dbFieldName, deferred, document, error, property, propertyName, ref, ref1, ref2;
      if (refresh == null) {
        refresh = false;
      }

      /*
      Save this document.
      @param refresh: {bool} Refresh the index after performing the operation.
      @returns {promise} (Document)
       */
      deferred = q.defer();
      if (this.version == null) {
        this.version = 0;
      }
      document = {};
      ref = this.constructor._properties;
      for (propertyName in ref) {
        property = ref[propertyName];
        if (!((ref1 = property.dbField) !== '_id' && ref1 !== '_version')) {
          continue;
        }
        dbFieldName = (ref2 = property.dbField) != null ? ref2 : propertyName;
        try {
          document[dbFieldName] = property.toDb(this);
        } catch (_error) {
          error = _error;
          deferred.reject(error);
          return deferred.promise;
        }
      }
      this.constructor._es.index({
        index: this.constructor.getIndexName(),
        type: this.constructor.getDocumentType(),
        refresh: refresh,
        id: this.id,
        version: this.version,
        body: document
      }, (function(_this) {
        return function(error, response) {
          if (error) {
            deferred.reject(error);
            return;
          }
          _this.id = response._id;
          _this.version = response._version;
          return deferred.resolve(_this);
        };
      })(this));
      return deferred.promise;
    };

    Document.prototype["delete"] = function(refresh) {
      var deferred;
      if (refresh == null) {
        refresh = false;
      }

      /*
      Delete this document.
      @returns {promise} (Document)
       */
      deferred = q.defer();
      this.constructor._es["delete"]({
        index: this.constructor.getIndexName(),
        type: this.constructor.getDocumentType(),
        refresh: refresh,
        id: this.id
      }, (function(_this) {
        return function(error) {
          if (error) {
            deferred.reject(error);
            return;
          }
          return deferred.resolve(_this);
        };
      })(this));
      return deferred.promise;
    };

    return Document;

  })();

}).call(this);
