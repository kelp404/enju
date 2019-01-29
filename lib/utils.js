(function() {
  var config, elasticsearch, properties, util,
    indexOf = [].indexOf;

  util = require('util');

  config = require('config');

  elasticsearch = require('elasticsearch');

  properties = require('./properties');

  module.exports = {
    getElasticsearch: function() {
      /*
      Get the connection for ElasticSearch.
      @returns {Elasticsearch.Client}
      */
      return new elasticsearch.Client(util._extend({}, config.enju.elasticsearchConfig));
    },
    getIndexPrefix: function() {
      var ref;
      /*
      Get index prefix.
      @returns {string}
      */
      return (ref = config.enju.indexPrefix) != null ? ref : '';
    },
    bleachRegexWords: function(value = '') {
      var i, len, result, table, word;
      value = `${value}`;
      table = '^$*+?{}.[]()\\|/';
      result = [];
      for (i = 0, len = value.length; i < len; i++) {
        word = value[i];
        if (indexOf.call(table, word) >= 0) {
          result.push(`\\${word}`);
        } else {
          result.push(word);
        }
      }
      return result.join('');
    },
    updateReferenceProperties: function(documents) {
      return new Promise(function(resolve, reject) {
        var dataTable, document, documentClassName, documentClasses, documentId, i, items, j, len, len1, property, propertyName, ref, referenceProperties, tasks;
        /*
        Fetch reference properties of documents.
        @param documents {list<Document>}
        @returns {promise}  The data will direct apply on the arguments.
        */
        if (!documents || !documents.length) {
          return resolve();
        }
        dataTable = {}; // {documentClassName: {documentId: {Document}}}
        documentClasses = {}; // {documentClassName: documentClass}
        referenceProperties = []; // all reference properties in documents
        ref = documents[0].constructor._properties;
        
        // scan what kind of documents should be fetched
        for (propertyName in ref) {
          property = ref[propertyName];
          if (property.constructor !== properties.ReferenceProperty) {
            continue;
          }
          if (!(property.referenceClass.name in dataTable)) {
            dataTable[property.referenceClass.name] = {};
            documentClasses[property.referenceClass.name] = property.referenceClass;
          }
          referenceProperties.push(property);
        }
// scan what id of documents should be fetched
        for (i = 0, len = documents.length; i < len; i++) {
          document = documents[i];
// loop all reference properties in the document
          for (j = 0, len1 = referenceProperties.length; j < len1; j++) {
            property = referenceProperties[j];
            documentId = document[property.propertyName];
            if (documentId) {
              dataTable[property.referenceClass.name][documentId] = null;
            }
          }
        }
        // fetch documents
        tasks = [];
        for (documentClassName in dataTable) {
          items = dataTable[documentClassName];
          tasks.push((function(documentClassName, items) {
            return documentClasses[documentClassName].get(Object.keys(items), false).then(function(referenceDocuments) {
              var k, len2, referenceDocument, results;
              results = [];
              for (k = 0, len2 = referenceDocuments.length; k < len2; k++) {
                referenceDocument = referenceDocuments[k];
                results.push(dataTable[documentClassName][referenceDocument.id] = referenceDocument);
              }
              return results;
            });
          })(documentClassName, items));
        }
        return Promise.all(tasks).then(function() {
          var k, l, len2, len3, resolveDocument;
// update reference properties of documents
          for (k = 0, len2 = documents.length; k < len2; k++) {
            document = documents[k];
// loop all reference properties in the document
            for (l = 0, len3 = referenceProperties.length; l < len3; l++) {
              property = referenceProperties[l];
              resolveDocument = dataTable[property.referenceClass.name][document[property.propertyName]];
              if (property.required && !resolveDocument) {
                console.log(`There are a reference class can't mapping: ${property.referenceClass.name}::${document[property.propertyName]}`);
                continue;
              }
              document[property.propertyName] = resolveDocument;
            }
          }
          return resolve();
        }).catch(function(error) {
          return reject(error);
        });
      });
    }
  };

}).call(this);
