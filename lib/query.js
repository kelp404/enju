(function() {
  var Query, QueryCell, QueryOperation, exceptions, properties, q,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  q = require('q');

  exceptions = require('./exceptions');

  properties = require('./properties');

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
      this.dbField = args.dbField, this.operation = args.operation, this.value = args.value, this.isIntersect = args.isIntersect, this.isUnion = args.isUnion;
      this.isContainsEmpty = this.operation === QueryOperation.contains && !this.value.length;
    }

    return QueryCell;

  })();

  module.exports = Query = (function() {
    function Query(documentClass, queryCells) {
      if (queryCells == null) {
        queryCells = [];
      }

      /*
      @param documentClass {constructor} The document's constructor.
       */
      this.documentClass = documentClass;
      this.queryCells = queryCells;
    }

    Query.updateReferenceProperties = function(documents) {

      /*
      Update reference properties of documents.
      @param documents {list} (Document)
      @returns {promise}
       */
      var dataTable, deferred, document, documentClassName, documentClasses, documentId, funcs, i, items, j, len, len1, property, propertyName, ref, referenceProperties;
      deferred = q.defer();
      if (!documents || !documents.length) {
        deferred.resolve();
        return;
      }
      dataTable = {};
      documentClasses = {};
      referenceProperties = [];
      ref = documents[0].constructor._properties;
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
      for (i = 0, len = documents.length; i < len; i++) {
        document = documents[i];
        for (j = 0, len1 = referenceProperties.length; j < len1; j++) {
          property = referenceProperties[j];
          documentId = document[property.propertyName];
          if (documentId) {
            dataTable[property.referenceClass.name][documentId] = null;
          }
        }
      }
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
      q.all(funcs)["catch"](function(error) {
        return deferred.reject(error);
      }).done(function() {
        var k, l, len2, len3, resolveDocument;
        for (k = 0, len2 = documents.length; k < len2; k++) {
          document = documents[k];
          for (l = 0, len3 = referenceProperties.length; l < len3; l++) {
            property = referenceProperties[l];
            resolveDocument = dataTable[property.referenceClass.name][document[property.propertyName]];
            if (property.required && !resolveDocument) {
              console.warning("There are a reference class can't mapping");
              continue;
            }
            document[property.propertyName] = resolveDocument;
          }
        }
        return deferred.resolve();
      });
      return deferred.promise;
    };

    Query.prototype.where = function(field, operation) {

      /*
      It is intersect.
       */
      return this.intersect(field, operation);
    };

    Query.prototype.intersect = function(field, operation) {

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
        subQuery = field(new Query(this.documentClass));
        this.queryCells.push(subQuery.queryCells);
      } else {
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
          throw new exceptions.SyntaxError(field + " not in " + this.documentClass.name);
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
          dbField = (ref2 = this.documentClass._properties[field].dbField) != null ? ref2 : field;
        } else {
          dbField = (ref3 = field.dbField) != null ? ref3 : field.propertyName;
        }
        this.queryCells.push(new QueryCell({
          dbField: dbField,
          operation: QueryOperation.convertOperation(firstOperation),
          value: value,
          isIntersect: true
        }));
      }
      return this;
    };

    Query.prototype.union = function(field, operation) {

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
      var allFields, dbField, firstOperation, property, propertyName, ref, ref1, ref2, ref3, value;
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
        throw new exceptions.SyntaxError(field + " not in " + this.documentClass.name);
      }
      firstOperation = null;
      value = null;
      for (firstOperation in operation) {
        value = operation[firstOperation];
        break;
      }
      if (typeof field === 'string') {
        dbField = (ref2 = this.documentClass._properties[field].dbField) != null ? ref2 : field;
      } else {
        dbField = (ref3 = field.dbField) != null ? ref3 : field.propertyName;
      }
      this.queryCells.push(new QueryCell({
        dbField: dbField,
        operation: QueryOperation.convertOperation(firstOperation),
        value: value,
        isUnion: true
      }));
      return this;
    };

    Query.prototype.orderBy = function(field, descending) {
      var allFields, dbField, operationCode, property, propertyName, ref, ref1, ref2, ref3;
      if (descending == null) {
        descending = false;
      }

      /*
      Append the order query.
      @param member {Property|string} The property name of the document.
      @param descending {bool} Is sorted by descending?
      @returns {Query}
       */
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
        throw new exceptions.SyntaxError(field + " not in " + this.documentClass.name);
      }
      if (descending) {
        operationCode = QueryOperation.orderDESC;
      } else {
        operationCode = QueryOperation.orderASC;
      }
      if (typeof field === 'string') {
        dbField = (ref2 = this.documentClass._properties[field].dbField) != null ? ref2 : field;
      } else {
        dbField = (ref3 = field.dbField) != null ? ref3 : field.propertyName;
      }
      this.queryCells.push(new QueryCell({
        dbField: dbField,
        operation: operationCode
      }));
      return this;
    };

    Query.prototype.fetch = function(args) {
      var deferred, queryObject;
      if (args == null) {
        args = {};
      }

      /*
      Fetch documents by this query.
      @param args {object}
          limit: {number} The size of the pagination. (The limit of the result items.) default is 1000
          skip: {number} The offset of the pagination. (Skip x items.) default is 0
          fetchReference: {bool} Fetch documents of reference properties. default is true.
      @returns {promise} ({items: {Document}, total: {number})
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
      }, (function(_this) {
        return function(error, response) {
          var items, total;
          if (error) {
            deferred.reject(error);
            return;
          }
          items = (function() {
            var dbField, hit, i, item, len, property, propertyName, ref, ref1, ref2, result;
            result = [];
            ref = response.hits.hits;
            for (i = 0, len = ref.length; i < len; i++) {
              hit = ref[i];
              item = {
                id: hit._id,
                version: hit._version
              };
              ref1 = _this.documentClass._properties;
              for (propertyName in ref1) {
                property = ref1[propertyName];
                dbField = (ref2 = property.dbField) != null ? ref2 : propertyName;
                if (dbField in hit._source) {
                  item[propertyName] = hit._source[dbField];
                }
              }
              result.push(new _this.documentClass(item));
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
        };
      })(this));
      return deferred.promise;
    };

    Query.prototype.first = function(fetchReference) {
      var args, deferred;
      if (fetchReference == null) {
        fetchReference = true;
      }

      /*
      Fetch the first document by this query.
      @param fetchReference {bool}
      @returns {promise} ({Document|null})
       */
      deferred = q.defer();
      args = {
        limit: 1,
        skip: 0,
        fetchReference: fetchReference
      };
      this.fetch(args).then(function(result) {
        return deferred.resolve(result.items.length ? result.items[0] : null);
      })["catch"](function(error) {
        return deferred.reject(error);
      });
      return deferred.promise;
    };

    Query.prototype.count = function() {

      /*
      Count documents by the query.
      @returns {promise} ({number})
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
    };

    Query.prototype.compileQueries = function() {

      /*
      Compile query cells to elasticsearch query object.
      @returns {object}
          query: {object}
          sort: {list}
          isContainsEmpty: {bool}
       */
      var elasticsearchQuery, i, index, isContainsEmpty, j, len, minimumMatch, obj, obj1, queries, queryCell, ref, ref1, result, sort, subQuery;
      queries = [];
      sort = [];
      isContainsEmpty = false;
      ref = this.queryCells;
      for (i = 0, len = ref.length; i < len; i++) {
        queryCell = ref[i];
        if (queryCell.constructor === Array) {
          subQuery = new Query(this.documentClass, queryCell);
          elasticsearchQuery = subQuery.compileQueries();
          if (elasticsearchQuery.isContainsEmpty) {
            continue;
          }
          queries.push(elasticsearchQuery.query);
          continue;
        }
        if (queryCell.isContainsEmpty) {
          isContainsEmpty = true;
          break;
        }
        switch (queryCell.operation) {
          case QueryOperation.orderASC:
            sort.push((
              obj = {},
              obj["" + queryCell.dbField] = {
                order: 'asc',
                ignore_unmapped: true,
                missing: '_first'
              },
              obj
            ));
            break;
          case QueryOperation.orderDESC:
            sort.push((
              obj1 = {},
              obj1["" + queryCell.dbField] = {
                order: 'desc',
                ignore_unmapped: true,
                missing: '_last'
              },
              obj1
            ));
            break;
          default:
            queries.push(this.compileQuery(queryCell));
        }
      }
      result = {
        sort: sort
      };
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
    };

    Query.prototype.compileQuery = function(queryCell) {

      /*
      @param queryCell: {QueryCell}
      @returns {object}
       */
      var obj, obj1, obj2, obj3, obj4, obj5, obj6, obj7, obj8, obj9, x;
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
          break;
        case QueryOperation.greater:
          return {
            range: (
              obj2 = {},
              obj2["" + queryCell.dbField] = {
                gt: queryCell.value
              },
              obj2
            )
          };
        case QueryOperation.greaterEqual:
          return {
            range: (
              obj3 = {},
              obj3["" + queryCell.dbField] = {
                gte: queryCell.value
              },
              obj3
            )
          };
        case QueryOperation.less:
          return {
            range: (
              obj4 = {},
              obj4["" + queryCell.dbField] = {
                lt: queryCell.value
              },
              obj4
            )
          };
        case QueryOperation.lessEqual:
          return {
            range: (
              obj5 = {},
              obj5["" + queryCell.dbField] = {
                lte: queryCell.value
              },
              obj5
            )
          };
        case QueryOperation.contains:
          return {
            bool: {
              should: (function() {
                var i, len, obj6, ref, results;
                ref = queryCell.value;
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  x = ref[i];
                  results.push({
                    match: (
                      obj6 = {},
                      obj6["" + queryCell.dbField] = {
                        query: x,
                        operator: 'and'
                      },
                      obj6
                    )
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
                var i, len, obj6, ref, results;
                ref = queryCell.value;
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  x = ref[i];
                  results.push({
                    bool: {
                      must_not: {
                        match: (
                          obj6 = {},
                          obj6["" + queryCell.dbField] = {
                            query: x,
                            operator: 'and'
                          },
                          obj6
                        )
                      }
                    }
                  });
                }
                return results;
              })()
            }
          };
        case QueryOperation.like:
          return {
            bool: {
              should: [
                {
                  match: (
                    obj6 = {},
                    obj6["" + queryCell.dbField] = {
                      query: queryCell.value,
                      operator: 'and'
                    },
                    obj6
                  )
                }, {
                  regexp: (
                    obj7 = {},
                    obj7["" + queryCell.dbField] = '.*%s.*' % queryCell.value,
                    obj7
                  )
                }
              ]
            }
          };
        case QueryOperation.unlike:
          return {
            bool: {
              minimum_should_match: 2,
              should: [
                {
                  bool: {
                    must_not: {
                      match: (
                        obj8 = {},
                        obj8["" + queryCell.dbField] = {
                          query: queryCell.value,
                          operator: 'and'
                        },
                        obj8
                      )
                    }
                  }
                }, {
                  bool: {
                    must_not: {
                      regexp: (
                        obj9 = {},
                        obj9["" + queryCell.dbField] = '.*%s.*' % queryCell.value,
                        obj9
                      )
                    }
                  }
                }
              ]
            }
          };
      }
    };

    return Query;

  })();

}).call(this);
