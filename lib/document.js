(function() {
  var Document, Query, exceptions, properties, utils;

  utils = require('./utils');

  Query = require('./query');

  properties = require('./properties');

  exceptions = require('./exceptions');

  module.exports = Document = class Document {
    /*
    You have to call define() to define your document.
    @property _index {string} You can set index name by this attribute.
    @property _type {string} You can set type of the document. The default is class name.
    @property _settings {object} You can set index settings by this attribute.
    @property id {string}
    @property version {number}
    @property _properties {object} {'propertyName': {Property}}
    @property _es {Elasticsearch.Client}
    */
    constructor(args = {}) {
      var property, propertyName, ref;
      ref = this.constructor._properties;
      for (propertyName in ref) {
        property = ref[propertyName];
        this[propertyName] = property.toJs(args[propertyName]);
      }
    }

    // -----------------------------------------------------
    // private methods
    // -----------------------------------------------------
    static getIndexName() {
      /*
      Get the index name with prefix.
      @returns: {string}
      */
      return `${utils.getIndexPrefix()}${this._index}`;
    }

    static getDocumentType() {
      var ref;
      /*
      Get the document type.
      @returns {string}
      */
      return (ref = this._type) != null ? ref : this.name;
    }

    // -----------------------------------------------------
    // public methods
    // -----------------------------------------------------
    static define() {
      var DynamicClass, defined, property, propertyName;
      /*
      1. define properties with class name.
          @param className: {string}
          @param properties: {object}
          @returns {constructor}
      2. define properties for this document.
          @param properties: {object}
      */
      this._properties = {
        id: new properties.StringProperty({
          dbField: '_id'
        }),
        version: new properties.IntegerProperty({
          dbField: '_version'
        })
      };
      this._es = utils.getElasticsearch();
      if (arguments.length === 2 && typeof arguments[0] === 'string' && typeof arguments[1] === 'object') {
        // 1. define properties with class name.
        defined = arguments[1];
        if (defined._type == null) {
          defined._type = arguments[0];
        }
        DynamicClass = (function() {
          class DynamicClass extends this {};

          DynamicClass.define(defined);

          return DynamicClass;

        }).call(this);
        return DynamicClass;
      } else if (arguments.length === 1 && typeof arguments[0] === 'object') {
        // 2. define properties for this document.
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
      throw new exceptions.ArgumentError('Argument error for enju.Document.define()');
    }

    static get(ids, fetchReference = true) {
      return new Promise((resolve, reject) => {
        var x;
        /*
        Fetch the document with id or ids.
        If the document is not exist, it will return null.
        @param ids {string|list}
        @param fetchReference {bool} Fetch reference data of this document.
        @returns {promise} (Document|null|list)
        */
        // the empty document
        if ((ids == null) || ids === '') {
          return resolve(null);
        }
        // empty documents
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
            return resolve([]);
          }
        }
        // fetch documents
        if (ids.constructor === Array) {
          this._es.mget({
            index: this.getIndexName(),
            type: this.getDocumentType(),
            body: {
              ids: ids
            }
          }, (error, response) => {
            var dbField, doc, i, item, len, property, propertyName, ref, ref1, ref2, result;
            if (error) {
              return reject(error);
            }
            result = [];
            ref = response.docs;
            for (i = 0, len = ref.length; i < len; i++) {
              doc = ref[i];
              if (!doc.found) {
                continue;
              }
              item = {
                id: doc._id,
                version: doc._version
              };
              ref1 = this._properties;
              for (propertyName in ref1) {
                property = ref1[propertyName];
                dbField = (ref2 = property.dbField) != null ? ref2 : propertyName;
                if (dbField in doc._source) {
                  item[propertyName] = doc._source[dbField];
                }
              }
              result.push(new this(item));
            }
            // call resolve()
            if (fetchReference) {
              return Query.updateReferenceProperties(result).then(function() {
                return resolve(result);
              }).catch(function(error) {
                return reject(error);
              });
            } else {
              return resolve(result);
            }
          });
          return;
        }
        // fetch the document
        return this._es.get({
          index: this.getIndexName(),
          type: this.getDocumentType(),
          id: ids
        }, (error, response) => {
          var args, dbField, document, property, propertyName, ref, ref1;
          if (error) {
            if (error.status === 404) {
              return resolve(null);
            }
            return reject(error);
          }
          args = {
            id: response._id,
            version: response._version
          };
          ref = this._properties;
          for (propertyName in ref) {
            property = ref[propertyName];
            dbField = (ref1 = property.dbField) != null ? ref1 : propertyName;
            if (dbField in response._source) {
              args[propertyName] = response._source[dbField];
            }
          }
          // call resolve()
          document = new this(args);
          if (fetchReference) {
            return Query.updateReferenceProperties([document]).then(function() {
              return resolve(document);
            }).catch(function(error) {
              return reject(error);
            });
          } else {
            return resolve(document);
          }
        });
      });
    }

    static exists(id) {
      return new Promise((resolve, reject) => {
        /*
        Is the document exists?
        @param id {string} The documents' id.
        @returns {promise<bool>}
        */
        return this._es.exists({
          index: this.getIndexName(),
          type: this.getDocumentType(),
          id: id
        }, function(error, response) {
          if (error) {
            return reject(error);
          }
          return resolve(response);
        });
      });
    }

    static all() {
      /*
      Generate a query for this document.
      @returns {Query}
      */
      return new Query(this);
    }

    static where(field, operation) {
      /*
      Generate the query for this document.
      Please via Query.intersect().
      */
      var query;
      query = new Query(this);
      return query.intersect(field, operation);
    }

    static refresh(args = {}) {
      return new Promise((resolve, reject) => {
        /*
        Explicitly refresh one or more index, making all operations performed since the last refresh available for search.
        https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/api-reference-5-6.html#api-indices-refresh-5-6
        @params args {object}
        @returns {promise}
        */
        args.index = this.getIndexName();
        return this._es.indices.refresh(args, function(error) {
          if (error) {
            return reject(error);
          }
          return resolve();
        });
      });
    }

    static updateMapping() {
      /*
      Update the index mapping.
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
      https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
      @returns {promise}
      */
      var closeIndex, createIndex, openIndex, putMapping, putSettings;
      createIndex = () => {
        return new Promise((resolve, reject) => {
          return this._es.indices.create({
            index: this.getIndexName()
          }, function(error, response) {
            if (error && error.status !== 400) {
              return reject(error);
            }
            return setTimeout(function() {
              return resolve(response);
            }, 1000);
          });
        });
      };
      closeIndex = () => {
        return new Promise((resolve, reject) => {
          return this._es.indices.close({
            index: this.getIndexName()
          }, function(error, response) {
            if (error) {
              return reject(error);
            }
            return resolve(response);
          });
        });
      };
      putSettings = () => {
        return new Promise((resolve, reject) => {
          if (!this._settings) {
            return resolve();
          }
          return this._es.indices.putSettings({
            index: this.getIndexName(),
            body: {
              settings: {
                index: this._settings
              }
            }
          }, function(error, response) {
            if (error) {
              return reject(error);
            }
            return resolve(response);
          });
        });
      };
      putMapping = () => {
        return new Promise((resolve, reject) => {
          var field, mapping, property, propertyName, ref, ref1, ref2, ref3;
          mapping = {};
          ref = this._properties;
          for (propertyName in ref) {
            property = ref[propertyName];
            if ((ref1 = property.dbField) === '_id' || ref1 === '_version') {
              // don't set the mapping to _id and _version
              continue;
            }
            if (property.mapping) {
              // there is an object in this field
              mapping[(ref2 = property.dbField) != null ? ref2 : propertyName] = {
                properties: property.mapping
              };
              continue;
            }
            field = {};
            switch (property.constructor) {
              case properties.StringProperty:
                field.type = 'string';
                break;
              case properties.BooleanProperty:
                field.type = 'boolean';
                break;
              case properties.IntegerProperty:
                field.type = 'long';
                break;
              case properties.FloatProperty:
                field.type = 'double';
                break;
              case properties.DateProperty:
                field.type = 'date';
                field.format = 'strict_date_optional_time||epoch_millis';
                break;
              case properties.ReferenceProperty:
                field.type = 'string';
                field.analyzer = 'keyword';
                break;
              case properties.ListProperty:
                switch (property.itemClass) {
                  case properties.StringProperty:
                    field.type = 'string';
                    break;
                  case properties.BooleanProperty:
                    field.type = 'boolean';
                    break;
                  case properties.IntegerProperty:
                    field.type = 'long';
                    break;
                  case properties.FloatProperty:
                    field.type = 'double';
                    break;
                  case properties.DateProperty:
                    field.type = 'date';
                    field.format = 'strict_date_optional_time||epoch_millis';
                    break;
                  case properties.ReferenceProperty:
                    field.type = 'string';
                    field.analyzer = 'keyword';
                }
            }
            if (property.type) {
              field.type = property.type;
            }
            if (property.analyzer) {
              field.analyzer = property.analyzer;
            }
            if (property.index) {
              field.index = property.index;
            }
            if (Object.keys(field).length) {
              mapping[(ref3 = property.dbField) != null ? ref3 : propertyName] = field;
            }
          }
          return this._es.indices.putMapping({
            index: this.getIndexName(),
            type: this.getDocumentType(),
            body: {
              properties: mapping
            }
          }, function(error, response) {
            if (error) {
              return reject(error);
            }
            return resolve(response);
          });
        });
      };
      openIndex = () => {
        return new Promise((resolve, reject) => {
          return this._es.indices.open({
            index: this.getIndexName()
          }, function(error, response) {
            if (error) {
              return reject(error);
            }
            return resolve(response);
          });
        });
      };
      return createIndex().then(closeIndex).then(putSettings).then(putMapping).then(openIndex).then(() => {
        return console.log(`updated mapping [${this.getIndexName()}]`);
      }).catch(function(error) {
        console.error(error);
        throw error;
      });
    }

    save(refresh = false) {
      return new Promise((resolve, reject) => {
        var convertError, dbFieldName, document, error, property, propertyName, ref, ref1, ref2;
        /*
        Save this document.
        @param refresh {bool} Refresh the index after performing the operation.
        @returns {promise<Document>}
        */
        document = {}; // it will be written to database
        convertError = null;
        ref = this.constructor._properties;
        for (propertyName in ref) {
          property = ref[propertyName];
          if (!((ref1 = property.dbField) !== '_id' && ref1 !== '_version')) {
            continue;
          }
          dbFieldName = (ref2 = property.dbField) != null ? ref2 : propertyName;
          try {
            document[dbFieldName] = property.toDb(this);
          } catch (error1) {
            error = error1;
            convertError = error;
          }
        }
        if (convertError != null) {
          return reject(convertError);
        }
        return this.constructor._es.index({
          index: this.constructor.getIndexName(),
          type: this.constructor.getDocumentType(),
          refresh: refresh,
          id: this.id,
          version: this.version != null ? this.version + 1 : 0,
          versionType: 'external',
          body: document
        }, (error, response) => {
          if (error) {
            return reject(error);
          }
          this.id = response._id;
          this.version = response._version;
          return resolve(this);
        });
      });
    }

    delete(refresh = false) {
      return new Promise((resolve, reject) => {
        /*
        Delete this document.
        @returns {promise<Document>}
        */
        return this.constructor._es.delete({
          index: this.constructor.getIndexName(),
          type: this.constructor.getDocumentType(),
          refresh: refresh,
          id: this.id
        }, (error) => {
          if (error) {
            return reject(error);
          }
          return resolve(this);
        });
      });
    }

  };

}).call(this);
