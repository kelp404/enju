(function() {
  var Query, QueryCell, QueryOperation;

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

    QueryOperation.intersection = 'intersection';

    QueryOperation.union = 'union';

    QueryOperation.all = 'all';

    return QueryOperation;

  })();

  QueryCell = (function() {
    function QueryCell(operation1, field1, value, subQueries) {
      this.operation = operation1;
      this.field = field1;
      this.value = value;
      this.subQueries = subQueries;
    }

    return QueryCell;

  })();

  module.exports = Query = (function() {
    function Query(documentClass) {
      this.isContainsEmpty = false;
      this.documentClass = documentClass;
      this.items = [QueryCell(QueryOperation.all)];
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
      @param field: {string|function}
          string: The field name of the document.
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

    return Query;

  })();

}).call(this);
