(function() {
  var Query, QueryCell, QueryOperation, exceptions, q;

  q = require('q');

  exceptions = require('./exceptions');

  QueryOperation = (function() {
    function QueryOperation() {}

    QueryOperation.unequal = 'unequal';

    QueryOperation.equal = 'equal';

    QueryOperation.less = 'less';

    QueryOperation.lessEqual = 'lessEqual';

    QueryOperation.greater = 'greater';

    QueryOperation.greaterEqual = 'greaterEqual';

    QueryOperation.like = 'like';

    QueryOperation.unlike = 'unlike';

    QueryOperation.contains = 'contains';

    QueryOperation.exclude = 'exclude';

    QueryOperation.orderASC = 'orderASC';

    QueryOperation.orderDESC = 'orderDESC';

    QueryOperation.convertOperation = function(value) {
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
          throw new exceptions.OperationError("There is no [" + value + "] operation.");
      }
    };

    return QueryOperation;

  })();

  QueryCell = (function() {
    function QueryCell(args) {
      this.dbField = args.dbField, this.operation = args.operation, this.value = args.value;
      this.isContainsEmpty = this.operation === QueryOperation.contains && !this.value.length;
    }

    return QueryCell;

  })();

  module.exports = Query = (function() {
    function Query(documentClass) {

      /*
      @param documentClass {constructor} The document's constructor.
       */
      this.documentClass = documentClass;
      this.queryCells = [];
    }

    Query.prototype.where = function(field, operation) {

      /*
      It is intersect.
       */
      return this.intersect(field, operation);
    };

    Query.prototype.intersect = function(field, operation) {

      /*
      Append a query as intersect.
      @param field: {Property|string|function}
          Property: The property of the document.
          string: The property name of the document.
          function: The sub query.
      @param operation: {object}
          key: [
              '!='
              '=='
              '<'
              '<='
              '>'
              '>='
              'like'
              'unlike'
              'contains'
              'exclude'
          ]
      @returns {Query}
       */
      var dbField, ref, value;
      if (typeof field === 'function') {

      } else {
        operation = null;
        value = null;
        for (operation in operation) {
          value = operation[operation];
          break;
        }
        dbField = typeof field === 'string' ? field : (ref = field.dbField) != null ? ref : field.propertyName;
        this.queryCells.push(new QueryCell({
          dbField: dbField,
          operation: QueryOperation.convertOperation(operation),
          value: value
        }));
      }
      return this;
    };

    Query.prototype.union = function(field, operation) {

      /*
      Append a query as intersect.
      @param field: {Property|string|function}
          Property: The property of the document.
          string: The property name of the document.
          function: The sub query.
      @param operation: {object}
          key: [
              '!='
              '=='
              '<'
              '<='
              '>'
              '>='
              'like'
              'unlike'
              'contains'
              'exclude'
          ]
      @returns {Query}
       */
      return this;
    };

    Query.prototype.fetch = function(args) {
      var deferred, queryObject;
      if (args == null) {
        args = {};
      }

      /*
      Fetch documents by this query.
      @param args: {object}
          limit: {number} The size of the pagination. (The limit of the result items.) default is 1000
          skip: {number} The offset of the pagination. (Skip x items.) default is 0
          fetchReference: {bool} Fetch documents of reference properties. default is true.
      @returns {promise} (object)
          items: [Document, ...]
          total: {number}
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
          query: queryObject.query
        },
        from: args.skip,
        size: args.limit,
        sort: queryObject.sort,
        fields: ['_source'],
        version: true
      }, (function(_this) {
        return function(error, response) {
          if (error) {
            deferred.reject(error);
            return;
          }
          return deferred.resolve({
            items: (function() {
              var hit, i, item, len, ref, result;
              result = [];
              ref = response.hits.hits;
              for (i = 0, len = ref.length; i < len; i++) {
                hit = ref[i];
                item = hit._source;
                item.id = hit._id;
                item.version = hit._version;
                result.push(new _this.documentClass(item));
              }
              return result;
            })(),
            total: response.hits.total
          });
        };
      })(this));
      return deferred.promise;
    };

    Query.prototype.compileQueries = function() {

      /*
      Compile query cells to elasticsearch query object.
      @returns {object}
          query: {object}
          sort: {list}
          isContainsEmpty: {bool}
       */
      var i, isContainsEmpty, len, query, queryCell, ref, result, sort;
      query = [];
      sort = [];
      isContainsEmpty = false;
      ref = this.queryCells;
      for (i = 0, len = ref.length; i < len; i++) {
        queryCell = ref[i];
        if (queryCell.constructor === Array) {
          continue;
        }
        if (queryCell.isContainsEmpty) {
          isContainsEmpty = true;
          break;
        }
        switch (queryCell.operation) {
          case QueryOperation.orderASC:
            console.log('-');
            break;
          case QueryOperation.orderDESC:
            console.log('-');
            break;
          default:
            query.push(this.compileQuery(queryCell));
        }
      }
      result = {
        sort: sort
      };
      if (isContainsEmpty) {
        result.isContainsEmpty = true;
      } else if (query.length === 0) {
        result.query = {
          match_all: {}
        };
      } else if (query.length === 1) {
        result.query = query[0];
      } else {
        result.query = {
          bool: {
            should: query,
            minimum_should_match: query.length
          }
        };
      }
      return result;
    };

    Query.prototype.compileQuery = function(queryCell) {

      /*
      @param queryCell: {QueryCell}
      @returns {object}
       */
      var obj, obj1;
      switch (queryCell.operation) {
        case QueryOperation.equal:
          if (queryCell.value != null) {
            return {
              match: (
                obj = {},
                obj["" + queryCell.dbField] = {
                  query: queryCell.value,
                  operator: 'and'
                },
                obj
              )
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
                  match: (
                    obj1 = {},
                    obj1["" + queryCell.dbField] = {
                      query: queryCell.value,
                      operator: 'and'
                    },
                    obj1
                  )
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
      }
    };

    return Query;

  })();

}).call(this);
