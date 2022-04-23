(function() {
  var Query, QueryCell, QueryOperation, exceptions, properties, utils,
    indexOf = [].indexOf;

  exceptions = require('./exceptions');

  properties = require('./properties');

  utils = require('./utils');

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
      @param field {string|function}
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
      var allFields, dbField, firstOperation, previousQueryCell, property, propertyName, ref, ref1, ref2, ref3, refactorQueryCells, subQuery, value;
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
        dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
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
      var allFields, dbField, firstOperation, property, propertyName, ref, ref1, ref2, ref3, value;
      /*
      Append a query as intersect.
      @param field {string} The property name of the document.
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
      dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
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
      @param member {string} The property name of the document.
      @param descending {bool} Is sorted by descending?
      @returns {Query}
      */
      var allFields, dbField, operationCode, property, propertyName, ref, ref1, ref2, ref3;
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
      dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
      this.queryCells.push(new QueryCell({
        dbField: dbField,
        operation: operationCode
      }));
      return this;
    }

    fetch(args = {}) {
      return new Promise((resolve, reject) => {
        var previousError, queryObject;
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
        queryObject = this.compileQueries();
        if (queryObject.isContainsEmpty) {
          resolve({
            items: [],
            total: 0
          });
          return;
        }
        previousError = new Error('From previous stack');
        return this.documentClass._es.search({
          index: this.documentClass.getIndexName(),
          body: {
            query: queryObject.query,
            sort: queryObject.sort
          },
          from: args.skip,
          size: args.limit,
          version: true
        }, (error, response) => {
          var items, total;
          if (error) {
            error.stack += previousError.stack;
            return reject(error);
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
            return utils.updateReferenceProperties(items).then(function() {
              return resolve({
                items: items,
                total: total
              });
            }).catch(function(error) {
              return reject(error);
            });
          } else {
            return resolve({
              items: items,
              total: total
            });
          }
        });
      });
    }

    first(fetchReference = true) {
      /*
      Fetch the first document by this query.
      @param fetchReference {bool}
      @returns {promise<Document|null>}
      */
      return this.fetch({
        limit: 1,
        skip: 0,
        fetchReference: fetchReference
      }).then(function(result) {
        if (result.items.length) {
          return result.items[0];
        } else {
          return null;
        }
      });
    }

    count() {
      return new Promise((resolve, reject) => {
        /*
        Count documents by the query.
        @returns {promise<number>}
        */
        var previousError, queryObject;
        queryObject = this.compileQueries();
        previousError = new Error('From previous stack');
        return this.documentClass._es.count({
          index: this.documentClass.getIndexName(),
          body: {
            query: queryObject.query
          }
        }, function(error, response) {
          if (error) {
            error.stack += previousError.stack;
            return reject(error);
          }
          return resolve(response.count);
        });
      });
    }

    sum(field) {
      return new Promise((resolve, reject) => {
        /*
        Sum the field of documents by the query.
        https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-sum-aggregation.html
        @param field {string} The property name of the document.
        @returns {promise<number>}
        */
        var allFields, dbField, previousError, property, propertyName, queryObject, ref, ref1, ref2, ref3;
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
          return reject(new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`));
        }
        dbField = (ref2 = (ref3 = this.documentClass._properties[field]) != null ? ref3.dbField : void 0) != null ? ref2 : field;
        queryObject = this.compileQueries();
        if (queryObject.isContainsEmpty) {
          return resolve(0);
        }
        previousError = new Error('From previous stack');
        return this.documentClass._es.search({
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
            error.stack += previousError.stack;
            return reject(error);
          }
          return resolve(response.aggregations.intraday_return.value);
        });
      });
    }

    groupBy(field, args = {}) {
      return new Promise((resolve, reject) => {
        var allFields, dbField, previousError, property, propertyName, queryObject, ref, ref1, ref2, ref3, ref4;
        /*
        Aggregations
        http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-aggregations.html
        @param field {string} The property name of the document.
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
          return reject(new exceptions.SyntaxError(`${field} not in ${this.documentClass.name}`));
        }
        dbField = (ref3 = (ref4 = this.documentClass._properties[field]) != null ? ref4.dbField : void 0) != null ? ref3 : field;
        queryObject = this.compileQueries();
        if (queryObject.isContainsEmpty) {
          return resolve([]);
        }
        previousError = new Error('From previous stack');
        return this.documentClass._es.search({
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
            error.stack += previousError.stack;
            return reject(error);
          }
          return resolve(response.aggregations.genres.buckets);
        });
      });
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
                missing: '_first'
              }
            });
            break;
          case QueryOperation.orderDESC:
            sort.push({
              [`${queryCell.dbField}`]: {
                order: 'desc',
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
      var value, x;
      /*
      @param queryCell: {QueryCell}
      @returns {object}
      */
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
              bool: {
                must_not: {
                  exists: {
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
                must: {
                  exists: {
                    field: queryCell.dbField
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
          value = utils.bleachRegexWords(queryCell.value);
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
          value = utils.bleachRegexWords(queryCell.value);
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
