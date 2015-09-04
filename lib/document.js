(function() {
  var Document, Query, config, exceptions, properties, q, utils;

  config = require('config');

  q = require('q');

  utils = require('./utils');

  Query = require('./query');

  properties = require('./properties');

  exceptions = require('./exceptions');

  module.exports = Document = (function() {

    /*
    @property _index: {string} You can set index name by this attribute.
    @property _settings: {object} You can set index settings by this attribute.
    @property id: {string}
    @property version: {number}
    @property _properties: {object} {'property_name': {Property}}
    @property _es: {Elasticsearch.Client}
    @property _className: {string}
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

    function Document() {}

    Document.getIndexName = function() {

      /*
      Get the index name with prefix.
      @returns: {string}
       */
      return "" + (utils.getIndexPrefix()) + this._index;
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
      var key, ref, value;
      if (arguments.length === 2 && typeof arguments[0] === 'string' && typeof arguments[1] === 'object') {

      } else if (arguments.length === 1 && typeof arguments[0] === 'object') {
        ref = arguments[0];
        for (key in ref) {
          value = ref[key];
          this._properties[key] = value;
        }
        return;
      }
      throw exceptions.ArgumentError('Argument error for enju.Document.define()');
    };

    Document.get = function(ids, fetchReference) {
      var deferred, es;
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
      if (ids.constructor === Array && ids.length === 0) {
        deferred.resolve([]);
        return deferred.promise;
      }
      es = utils.getElasticsearch();
      es.get({
        index: this.constructor.getIndexName(),
        type: this.constructor.name,
        id: ids
      }, function(error, response) {});
      return deferred.promise;
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
       */
      var closeIndex, createIndex, openIndex, putMapping, putSettings;
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
          var deferred, field, mapping, name, property, ref, ref1, ref2;
          deferred = q.defer();
          mapping = {};
          ref = _this._properties;
          for (name in ref) {
            property = ref[name];
            if ((ref1 = property.dbField) === '_id' || ref1 === '_version') {
              continue;
            }
            if (property.mapping) {
              mapping[name] = {
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
              mapping[name] = field;
            }
          }
          _this._es.indices.putMapping({
            index: _this.getIndexName(),
            type: (ref2 = _this._className) != null ? ref2 : _this.name,
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
      return createIndex().then(closeIndex).then(putSettings).then(putMapping).then(openIndex).then((function(_this) {
        return function() {
          return console.log("updated mapping [" + (_this.getIndexName()) + "]");
        };
      })(this), function(error) {
        console.error(error);
        throw error;
      });
    };

    return Document;

  })();

}).call(this);
