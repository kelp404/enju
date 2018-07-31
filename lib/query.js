(function() {
  var Query, QueryCell, QueryOperation, exceptions, properties, q,
    indexOf = [].indexOf;

  q = require('q');

  exceptions = require('./exceptions');

  properties = require('./properties');

  QueryOperation = (function() {
    class QueryOperation {
      static convertOperation(value) {
        switch (value) {
          case '!=':
          case QueryOperation.unequal:
            return QueryOperation.unequal;
          case '==':
          case QueryOperation.equal:
            return QueryOperation.equal;
          case '<':
          case QueryOperation.less:
            return QueryOperation.less;
          case '<=':
          case QueryOperation.lessEqual:
            return QueryOperation.lessEqual;
          case '>':
          case QueryOperation.greater:
            return QueryOperation.greater;
          case '>=':
          case QueryOperation.greaterEqual:
            return QueryOperation.greaterEqual;
          case QueryOperation.like:
            return QueryOperation.like;
          case QueryOperation.unlike:
            return QueryOperation.unlike;
          case QueryOperation.contains:
            return QueryOperation.contains;
          case QueryOperation.exclude:
            return QueryOperation.exclude;
          case QueryOperation.orderASC:
            return QueryOperation.orderASC;
          case QueryOperation.orderDESC:
            return QueryOperation.orderDESC;
          default:
            throw new exceptions.OperationError(`There is no [${value}] operation.`);
        }
      }

    };

    QueryOperation.unequal = 'unequal';

    QueryOperation.equal = 'equal';

    QueryOperation.less = 'less';

    QueryOperation.lessEqual = 'lessEqual';

    QueryOperation.greater = 'greater';

    QueryOperation.greaterEqual = 'greaterEqual';

    QueryOperation.like = 'like'; // only for string

    QueryOperation.unlike = 'unlike'; // only for string

    QueryOperation.contains = 'contains'; // it is mean `in`

    QueryOperation.exclude = 'exclude';

    QueryOperation.orderASC = 'orderASC';

    QueryOperation.orderDESC = 'orderDESC';

    return QueryOperation;

  }).call(this);

  QueryCell = class QueryCell {
    constructor(args) {
      ({dbField: this.dbField, operation: this.operation, value: this.value, isIntersect: this.isIntersect, isUnion: this.isUnion} = args);
      // if there is a query like .where('field', contains: []) it will be true.
      this.isContainsEmpty = this.operation === QueryOperation.contains && !this.value.length;
    }

  };

  module.exports = Query = class Query {
    constructor(documentClass, queryCells = []) {
      /*
      @param documentClass {constructor} The document's constructor.
      */
      this.documentClass = documentClass;
      this.queryCells = queryCells;
    }

    // -----------------------------------------------------
    // class methods
    // -----------------------------------------------------
    static updateReferenceProperties(documents) {
      /*
      Update reference properties of documents.
      @param documents {list<Document>}
      @returns {promise}
      */
      var dataTable, deferred, document, documentClassName, documentClasses, documentId, funcs, i, items, j, len, len1, property, propertyName, ref, referenceProperties;
      deferred = q.defer();
      if (!documents || !documents.length) {
        deferred.resolve();
        return deferred.promise;
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
      funcs = [];
      for (documentClassName in dataTable) {
        items = dataTable[documentClassName];
        funcs.push((function(documentClassName, items) {
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
      q.all(funcs).catch(function(error) {
        return deferred.reject(error);
      }).done(function() {
        var k, l, len2, len3, resolveDocument;
// update reference properties of documents
        for (k = 0, len2 = documents.length; k < len2; k++) {
          document = documents[k];
// loop all reference properties in the document
          for (l = 0, len3 = referenceProperties.length; l < len3; l++) {
            property = referenceProperties[l];
            resolveDocument = dataTable[property.referenceClass.name][document[property.propertyName]];
            if (property.required && !resolveDocument) {
              console.log("There are a reference class can't mapping");
              continue;
            }
            document[property.propertyName] = resolveDocument;
          }
        }
        return deferred.resolve();
      });
      return deferred.promise;
    }

    // -----------------------------------------------------
    // public methods
    // -----------------------------------------------------
    where(field, operation) {
      /*
      It is intersect.
      */
      return this.intersect(field, operation);
    }

    intersect(field, operation) {
      /*
      Append a query as intersect.
      @param field {Property|string|function}
          Property: The property of the document.
          string: The property name of the document.
          function: The sub query.
      @param operation {object}
          key: [
              '!=', 'unequal'
              '==', 'equal'
              '<', 'less'
              '<=', 'lessEqual'
              '>', 'greater',
              '>=', 'greaterEqual'
              'like'
              'unlike'
              'contains'
              'exclude'
          ]
      @returns {Query}
      */
      var allFields, dbField, firstOperation, previousQueryCell, property, propertyName, ref, ref1, ref2, ref3, ref4, refactorQueryCells, subQuery, value;
      refactorQueryCells = function() {
        /*
        If the last query cell is union query cell, then we append the intersect query cell.
        We should let previous query cells be the sub query, the append this query cell.
        */
        var i, index, queryCells, ref;
        queryCells = [];
        for (index = i = ref = this.queryCells; i >= 0; index = i += -1) {
          queryCells.unshift(this.queryCells[index].pop());
          if (this.queryCells[index].isIntersect) {
            break;
          }
        }
        return this.queryCells.push(queryCells);
      };
      if (typeof field === 'function') {
        // .where (query) ->
        subQuery = field(new Query(this.documentClass));
        this.queryCells.push(subQuery.queryCells);
      } else {
        // .where Document.name, '==': 'Enju'
        allFields = [];
        ref = this.documentClass._properties;
        for (propertyName in ref) {
          property = ref[propertyName];
          allFields.push(propertyName);
          if (property.dbField) {
            allFields.push(property.dbField);
          }
        }
        if (typeof field === 'string' && (ref1 = field.split('.', 1)[0], indexOf.call(allFields, ref1) < 0)) {
          throw new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`);
        }
        previousQueryCell = this.queryCells.length ? this.queryCells[this.queryCells.length - 1] : null;
        if (previousQueryCell && previousQueryCell.constructor !== Array && previousQueryCell.isUnion) {
          refactorQueryCells();
        }
        firstOperation = null;
        value = null;
        for (firstOperation in operation) {
          value = operation[firstOperation];
          break;
        }
        if (typeof field === 'string') {
          dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
        } else {
          dbField = (ref4 = field.dbField) != null ? ref4 : field.propertyName;
        }
        this.queryCells.push(new QueryCell({
          dbField: dbField,
          operation: QueryOperation.convertOperation(firstOperation),
          value: value,
          isIntersect: true
        }));
      }
      return this;
    }

    union(field, operation) {
      var allFields, dbField, firstOperation, property, propertyName, ref, ref1, ref2, ref3, ref4, value;
      /*
      Append a query as intersect.
      @param field {Property|string}
          Property: The property of the document.
          string: The property name of the document.
      @param operation {object}
          key: [
              '!=', 'unequal'
              '==', 'equal'
              '<', 'less'
              '<=', 'lessEqual'
              '>', 'greater',
              '>=', 'greaterEqual'
              'like'
              'unlike'
              'contains'
              'exclude'
          ]
      @returns {Query}
      */
      if (!this.queryCells.length) {
        throw new exceptions.SyntaxError('Can not use .union() at the first query.');
      }
      allFields = [];
      ref = this.documentClass._properties;
      for (propertyName in ref) {
        property = ref[propertyName];
        allFields.push(propertyName);
        if (property.dbField) {
          allFields.push(property.dbField);
        }
      }
      if (typeof field === 'string' && (ref1 = field.split('.', 1)[0], indexOf.call(allFields, ref1) < 0)) {
        throw new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`);
      }
      firstOperation = null;
      value = null;
      for (firstOperation in operation) {
        value = operation[firstOperation];
        break;
      }
      if (typeof field === 'string') {
        dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
      } else {
        dbField = (ref4 = field.dbField) != null ? ref4 : field.propertyName;
      }
      this.queryCells.push(new QueryCell({
        dbField: dbField,
        operation: QueryOperation.convertOperation(firstOperation),
        value: value,
        isUnion: true
      }));
      return this;
    }

    orderBy(field, descending = false) {
      /*
      Append the order query.
      @param member {Property|string} The property name of the document.
      @param descending {bool} Is sorted by descending?
      @returns {Query}
      */
      var allFields, dbField, operationCode, property, propertyName, ref, ref1, ref2, ref3, ref4;
      allFields = [];
      ref = this.documentClass._properties;
      for (propertyName in ref) {
        property = ref[propertyName];
        allFields.push(propertyName);
        if (property.dbField) {
          allFields.push(property.dbField);
        }
      }
      if (typeof field === 'string' && (ref1 = field.split('.', 1)[0], indexOf.call(allFields, ref1) < 0)) {
        throw new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`);
      }
      if (descending) {
        operationCode = QueryOperation.orderDESC;
      } else {
        operationCode = QueryOperation.orderASC;
      }
      if (typeof field === 'string') {
        dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
      } else {
        dbField = (ref4 = field.dbField) != null ? ref4 : field.propertyName;
      }
      this.queryCells.push(new QueryCell({
        dbField: dbField,
        operation: operationCode
      }));
      return this;
    }

    fetch(args = {}) {
      var deferred, queryObject;
      /*
      Fetch documents by this query.
      @param args {object}
          limit: {number} The size of the pagination. (The limit of the result items.) default is 1000
          skip: {number} The offset of the pagination. (Skip x items.) default is 0
          fetchReference: {bool} Fetch documents of reference properties. default is true.
      @returns {promise<object>} ({items: {Document}, total: {number}})
      */
      if (args.limit == null) {
        args.limit = 1000;
      }
      if (args.skip == null) {
        args.skip = 0;
      }
      if (args.fetchReference == null) {
        args.fetchReference = true;
      }
      deferred = q.defer();
      queryObject = this.compileQueries();
      if (queryObject.isContainsEmpty) {
        deferred.resolve({
          items: [],
          total: 0
        });
        return deferred.promise;
      }
      this.documentClass._es.search({
        index: this.documentClass.getIndexName(),
        body: {
          query: queryObject.query,
          sort: queryObject.sort
        },
        from: args.skip,
        size: args.limit,
        fields: ['_source'],
        version: true
      }, (error, response) => {
        var items, total;
        if (error) {
          deferred.reject(error);
          return;
        }
        items = (() => {
          var dbField, hit, i, item, len, property, propertyName, ref, ref1, ref2, result;
          result = [];
          ref = response.hits.hits;
          for (i = 0, len = ref.length; i < len; i++) {
            hit = ref[i];
            item = {
              id: hit._id,
              version: hit._version
            };
            ref1 = this.documentClass._properties;
            for (propertyName in ref1) {
              property = ref1[propertyName];
              dbField = (ref2 = property.dbField) != null ? ref2 : propertyName;
              if (dbField in hit._source) {
                item[propertyName] = hit._source[dbField];
              }
            }
            result.push(new this.documentClass(item));
          }
          return result;
        })();
        total = response.hits.total;
        if (args.fetchReference) {
          return Query.updateReferenceProperties(items).then(function() {
            return deferred.resolve({
              items: items,
              total: total
            });
          });
        } else {
          return deferred.resolve({
            items: items,
            total: total
          });
        }
      });
      return deferred.promise;
    }

    first(fetchReference = true) {
      /*
      Fetch the first document by this query.
      @param fetchReference {bool}
      @returns {promise<Document|null>}
      */
      var args, deferred;
      deferred = q.defer();
      args = {
        limit: 1,
        skip: 0,
        fetchReference: fetchReference
      };
      this.fetch(args).then(function(result) {
        return deferred.resolve(result.items.length ? result.items[0] : null);
      }).catch(function(error) {
        return deferred.reject(error);
      });
      return deferred.promise;
    }

    hasAny() {
      /*
      Are there any documents match with the query?
      @returns {promise<bool>}
      */
      var deferred, queryObject;
      deferred = q.defer();
      queryObject = this.compileQueries();
      if (queryObject.isContainsEmpty) {
        deferred.resolve(false);
        return deferred.promise;
      }
      this.documentClass._es.searchExists({
        index: this.documentClass.getIndexName(),
        body: {
          query: queryObject.query
        }
      }).then(function(result) {
        return deferred.resolve(result.exists ? true : false);
      }).catch(function(error) {
        var ref;
        if ((error != null ? (ref = error.body) != null ? ref.exists : void 0 : void 0) === false) {
          return deferred.resolve(false);
        } else {
          return deferred.reject(error);
        }
      });
      return deferred.promise;
    }

    count() {
      /*
      Count documents by the query.
      @returns {promise<number>}
      */
      var deferred, queryObject;
      deferred = q.defer();
      queryObject = this.compileQueries();
      this.documentClass._es.count({
        index: this.documentClass.getIndexName(),
        body: {
          query: queryObject.query
        },
        size: 0
      }, function(error, response) {
        if (error) {
          deferred.reject(error);
          return;
        }
        return deferred.resolve(response.count);
      });
      return deferred.promise;
    }

    sum(field) {
      /*
      Sum the field of documents by the query.
      https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-sum-aggregation.html
      @param field {Property|string} The property name of the document.
      @returns {promise<number>}
      */
      var allFields, dbField, deferred, property, propertyName, queryObject, ref, ref1, ref2, ref3, ref4;
      allFields = [];
      ref = this.documentClass._properties;
      for (propertyName in ref) {
        property = ref[propertyName];
        allFields.push(propertyName);
        if (property.dbField) {
          allFields.push(property.dbField);
        }
      }
      if (typeof field === 'string' && (ref1 = field.split('.', 1)[0], indexOf.call(allFields, ref1) < 0)) {
        throw new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`);
      }
      if (typeof field === 'string') {
        dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
      } else {
        dbField = (ref4 = field.dbField) != null ? ref4 : field.propertyName;
      }
      deferred = q.defer();
      queryObject = this.compileQueries();
      if (queryObject.isContainsEmpty) {
        deferred.resolve(0);
        return deferred.promise;
      }
      this.documentClass._es.search({
        index: this.documentClass.getIndexName(),
        body: {
          query: queryObject.query,
          aggs: {
            intraday_return: {
              sum: {
                field: dbField
              }
            }
          }
        },
        size: 0
      }, (error, response) => {
        if (error) {
          deferred.reject(error);
          return;
        }
        return deferred.resolve(response.aggregations.intraday_return.value);
      });
      return deferred.promise;
    }

    groupBy(field, args = {}) {
      var allFields, dbField, deferred, property, propertyName, queryObject, ref, ref1, ref2, ref3, ref4, ref5;
      /*
      Aggregations
      http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-aggregations.html
      @param field {Property|string} The property name of the document.
      @param args {object}
          limit: {number}  Default is 1,000.
          order: {string} "count|term"  Default is "term".
          descending: {bool}  Default is no.
      @returns {promise<list<object>>}
          [{
              doc_count: {number}
              key: {string}
          }]
      */
      if (args.limit == null) {
        args.limit = 1000;
      }
      if ((ref = args.order) !== 'count' && ref !== 'term') {
        args.order = 'term';
      }
      if (args.descending == null) {
        args.descending = false;
      }
      allFields = [];
      ref1 = this.documentClass._properties;
      for (propertyName in ref1) {
        property = ref1[propertyName];
        allFields.push(propertyName);
        if (property.dbField) {
          allFields.push(property.dbField);
        }
      }
      if (typeof field === 'string' && (ref2 = field.split('.', 1)[0], indexOf.call(allFields, ref2) < 0)) {
        throw new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`);
      }
      if (typeof field === 'string') {
        dbField = (ref3 = (ref4 = this.documentClass._properties[field]) != null ? ref4.dbField : void 0) != null ? ref3 : field;
      } else {
        dbField = (ref5 = field.dbField) != null ? ref5 : field.propertyName;
      }
      deferred = q.defer();
      queryObject = this.compileQueries();
      if (queryObject.isContainsEmpty) {
        deferred.resolve([]);
        return deferred.promise;
      }
      this.documentClass._es.search({
        index: this.documentClass.getIndexName(),
        body: {
          query: queryObject.query,
          aggs: {
            genres: {
              terms: {
                field: dbField,
                size: args.limit,
                order: {
                  [`_${args.order}`]: args.descending ? 'desc' : 'asc'
                }
              }
            }
          }
        },
        size: 0
      }, (error, response) => {
        if (error) {
          deferred.reject(error);
          return;
        }
        return deferred.resolve(response.aggregations.genres.buckets);
      });
      return deferred.promise;
    }

    // -----------------------------------------------------
    // private methods
    // -----------------------------------------------------
    compileQueries() {
      /*
      Compile query cells to elasticsearch query object.
      @returns {object}
          query: {object}
          sort: {list}
          isContainsEmpty: {bool}
      */
      var elasticsearchQuery, i, index, isContainsEmpty, j, len, minimumMatch, queries, queryCell, ref, ref1, result, sort, subQuery;
      queries = [];
      sort = [];
      isContainsEmpty = false;
      ref = this.queryCells;
      for (i = 0, len = ref.length; i < len; i++) {
        queryCell = ref[i];
        if (queryCell.constructor === Array) {
          // there are sub queries at this query
          subQuery = new Query(this.documentClass, queryCell);
          elasticsearchQuery = subQuery.compileQueries();
          if (elasticsearchQuery.isContainsEmpty) {
            continue;
          }
          queries.push(elasticsearchQuery.query);
          continue;
        }
        // compile query cell to elasticsearch query object and append into queries
        if (queryCell.isContainsEmpty) {
          isContainsEmpty = true;
          break;
        }
        switch (queryCell.operation) {
          case QueryOperation.orderASC:
            sort.push({
              [`${queryCell.dbField}`]: {
                order: 'asc',
                ignore_unmapped: true,
                missing: '_first'
              }
            });
            break;
          case QueryOperation.orderDESC:
            sort.push({
              [`${queryCell.dbField}`]: {
                order: 'desc',
                ignore_unmapped: true,
                missing: '_last'
              }
            });
            break;
          default:
            queries.push(this.compileQuery(queryCell));
        }
      }
      result = {
        sort: sort
      };
      // append queries
      if (isContainsEmpty) {
        result.isContainsEmpty = true;
      } else if (queries.length === 0) {
        result.query = {
          match_all: {}
        };
      } else if (queries.length === 1) {
        result.query = queries[0];
      } else {
        result.query = {
          bool: {
            should: queries
          }
        };
        minimumMatch = true;
        for (index = j = ref1 = this.queryCells.length - 1; j >= 0; index = j += -1) {
          if (this.queryCells[index].constructor !== Array && this.queryCells[index].isUnion) {
            minimumMatch = false;
            break;
          }
        }
        if (minimumMatch) {
          result.query.bool.minimum_should_match = queries.length;
        }
      }
      return result;
    }

    compileQuery(queryCell) {
      /*
      @param queryCell: {QueryCell}
      @returns {object}
      */
      var bleachRegexCode, value, x;
      bleachRegexCode = function(value = '') {
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
      };
      switch (queryCell.operation) {
        case QueryOperation.equal:
          if (queryCell.value != null) {
            return {
              match: {
                [`${queryCell.dbField}`]: {
                  query: queryCell.value,
                  operator: 'and'
                }
              }
            };
          } else {
            return {
              filtered: {
                filter: {
                  missing: {
                    field: queryCell.dbField
                  }
                }
              }
            };
          }
          break;
        case QueryOperation.unequal:
          if (queryCell.value != null) {
            return {
              bool: {
                must_not: {
                  match: {
                    [`${queryCell.dbField}`]: {
                      query: queryCell.value,
                      operator: 'and'
                    }
                  }
                }
              }
            };
          } else {
            return {
              bool: {
                must_not: {
                  filtered: {
                    filter: {
                      missing: {
                        field: queryCell.dbField
                      }
                    }
                  }
                }
              }
            };
          }
          break;
        case QueryOperation.greater:
          return {
            range: {
              [`${queryCell.dbField}`]: {
                gt: queryCell.value
              }
            }
          };
        case QueryOperation.greaterEqual:
          return {
            range: {
              [`${queryCell.dbField}`]: {
                gte: queryCell.value
              }
            }
          };
        case QueryOperation.less:
          return {
            range: {
              [`${queryCell.dbField}`]: {
                lt: queryCell.value
              }
            }
          };
        case QueryOperation.lessEqual:
          return {
            range: {
              [`${queryCell.dbField}`]: {
                lte: queryCell.value
              }
            }
          };
        case QueryOperation.contains:
          return {
            bool: {
              should: (function() {
                var i, len, ref, results;
                ref = queryCell.value;
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  x = ref[i];
                  results.push({
                    match: {
                      [`${queryCell.dbField}`]: {
                        query: x,
                        operator: 'and'
                      }
                    }
                  });
                }
                return results;
              })()
            }
          };
        case QueryOperation.exclude:
          return {
            bool: {
              minimum_should_match: queryCell.value.length,
              should: (function() {
                var i, len, ref, results;
                ref = queryCell.value;
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  x = ref[i];
                  results.push({
                    bool: {
                      must_not: {
                        match: {
                          [`${queryCell.dbField}`]: {
                            query: x,
                            operator: 'and'
                          }
                        }
                      }
                    }
                  });
                }
                return results;
              })()
            }
          };
        case QueryOperation.like:
          value = bleachRegexCode(queryCell.value);
          return {
            bool: {
              should: [
                {
                  match: {
                    [`${queryCell.dbField}`]: {
                      query: queryCell.value,
                      operator: 'and'
                    }
                  }
                },
                {
                  regexp: {
                    [`${queryCell.dbField}`]: `.*${value}.*`
                  }
                }
              ]
            }
          };
        case QueryOperation.unlike:
          value = bleachRegexCode(queryCell.value);
          return {
            bool: {
              minimum_should_match: 2,
              should: [
                {
                  bool: {
                    must_not: {
                      match: {
                        [`${queryCell.dbField}`]: {
                          query: queryCell.value,
                          operator: 'and'
                        }
                      }
                    }
                  }
                },
                {
                  bool: {
                    must_not: {
                      regexp: {
                        [`${queryCell.dbField}`]: `.*${value}.*`
                      }
                    }
                  }
                }
              ]
            }
          };
      }
    }

  };

}).call(this);
