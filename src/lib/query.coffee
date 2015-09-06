q = require 'q'

exceptions = require './exceptions'


class QueryOperation
    @unequal = 'unequal'
    @equal = 'equal'
    @less = 'less'
    @lessEqual = 'lessEqual'
    @greater = 'greater'
    @greaterEqual = 'greaterEqual'
    @like = 'like'  # only for string
    @unlike = 'unlike'  # only for string
    @contains = 'contains'  # it is mean `in`
    @exclude = 'exclude'

    @orderASC = 'orderASC'
    @orderDESC = 'orderDESC'

    @convertOperation = (value) ->
        switch value
            when '!=', QueryOperation.unequal
                QueryOperation.unequal
            when '==', QueryOperation.equal
                QueryOperation.equal
            when '<', QueryOperation.less
                QueryOperation.less
            when '<=', QueryOperation.lessEqual
                QueryOperation.lessEqual
            when '>', QueryOperation.greater
                QueryOperation.greater
            when '>=', QueryOperation.greaterEqual
                QueryOperation.greaterEqual
            when QueryOperation.like
                QueryOperation.like
            when QueryOperation.unlike
                QueryOperation.unlike
            when QueryOperation.contains
                QueryOperation.contains
            when QueryOperation.exclude
                QueryOperation.exclude
            when QueryOperation.orderASC
                QueryOperation.orderASC
            when QueryOperation.orderDESC
                QueryOperation.orderDESC
            else
                throw new exceptions.OperationError("There is no [#{value}] operation.")


class QueryCell
    constructor: (args) ->
        {@dbField, @operation, @value} = args
        # if there is a query like .where('field', contains: []) it will be true.
        @isContainsEmpty = @operation is QueryOperation.contains and not @value.length


module.exports = class Query
    constructor: (documentClass) ->
        ###
        @param documentClass {constructor} The document's constructor.
        ###
        @documentClass = documentClass
        @queryCells = []


    # -----------------------------------------------------
    # public methods
    # -----------------------------------------------------
    where: (field, operation) ->
        ###
        It is intersect.
        ###
        @intersect field, operation
    intersect: (field, operation) ->
        ###
        Append a query as intersect.
        @param field {Property|string|function}
            Property: The property of the document.
            string: The property name of the document.
            function: The sub query.
        @param operation {object}
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
        ###
        if typeof(field) is 'function'
            # .where (query) ->

        else
            # .where Document.name, '==': 'Enju'
            firstOperation = null
            value = null
            for firstOperation, value of operation
                break
            if typeof(field) is 'string'
                dbField = @documentClass._properties[field].dbField ? field
            else
                dbField = field.dbField ? field.propertyName
            @queryCells.push new QueryCell
                dbField: dbField
                operation: QueryOperation.convertOperation firstOperation
                value: value
        @

    union: (field, operation) ->
        ###
        Append a query as intersect.
        @param field {Property|string|function}
            Property: The property of the document.
            string: The property name of the document.
            function: The sub query.
        @param operation {object}
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
        ###
        @

    orderBy: (field, descending=no) ->
        ###
        Append the order query.
        @param member: {Property|string} The property name of the document.
        @param descending: {bool} Is sorted by descending?
        @returns {Query}
        ###
        if descending
            operationCode = QueryOperation.orderDESC
        else
            operationCode = QueryOperation.orderASC
        if typeof(field) is 'string'
            dbField = @documentClass._properties[field].dbField ? field
        else
            dbField = field.dbField ? field.propertyName
        @queryCells.push new QueryCell
            dbField: dbField
            operation: operationCode
        @

    fetch: (args={}) ->
        ###
        Fetch documents by this query.
        @param args: {object}
            limit: {number} The size of the pagination. (The limit of the result items.) default is 1000
            skip: {number} The offset of the pagination. (Skip x items.) default is 0
            fetchReference: {bool} Fetch documents of reference properties. default is true.
        @returns {promise} ([Document, ...], {number})
        ###
        args.limit ?= 1000
        args.skip ?= 0
        args.fetchReference ?= yes

        deferred = q.defer()
        queryObject = @compileQueries()
        if queryObject.isContainsEmpty
            deferred.resolve
                items: []
                total: 0
            return deferred.promise

        @documentClass._es.search
            index: @documentClass.getIndexName()
            body:
                query: queryObject.query
                sort: queryObject.sort
            from: args.skip
            size: args.limit
            fields: ['_source']
            version: yes
        , (error, response) =>
            if error
                deferred.reject error
                return
            items = do =>
                result = []
                for hit in response.hits.hits
                    item =
                        id: hit._id
                        version: hit._version
                    for propertyName, property of @documentClass._properties
                        dbField = property.dbField ? propertyName
                        if dbField of hit._source
                            item[propertyName] = hit._source[dbField]
                    result.push new @documentClass(item)
                result
            total = response.hits.total
            deferred.resolve items, total

        deferred.promise


    # -----------------------------------------------------
    # private methods
    # -----------------------------------------------------
    compileQueries: ->
        ###
        Compile query cells to elasticsearch query object.
        @returns {object}
            query: {object}
            sort: {list}
            isContainsEmpty: {bool}
        ###
        query = []
        sort = []
        isContainsEmpty = no

        for queryCell in @queryCells
            if queryCell.constructor is Array
                # there are sub queries at this query
                continue

            if queryCell.isContainsEmpty
                isContainsEmpty = yes
                break
            switch queryCell.operation
                when QueryOperation.orderASC
                    sort.push
                        "#{queryCell.dbField}":
                            order: 'asc'
                            ignore_unmapped: yes
                            missing: '_first'
                when QueryOperation.orderDESC
                    sort.push
                        "#{queryCell.dbField}":
                            order: 'desc'
                            ignore_unmapped: yes
                            missing: '_last'
                else
                    query.push @compileQuery queryCell

        result =
            sort: sort
        # append query
        if isContainsEmpty
            result.isContainsEmpty = yes
        else if query.length is 0
            result.query =
                match_all: {}
        else if query.length is 1
            result.query = query[0]
        else
            result.query =
                bool:
                    should: query
                    minimum_should_match: query.length
        result

    compileQuery: (queryCell) ->
        ###
        @param queryCell: {QueryCell}
        @returns {object}
        ###
        switch queryCell.operation
            when QueryOperation.equal
                if queryCell.value?
                    match:
                        "#{queryCell.dbField}":
                            query: queryCell.value
                            operator: 'and'
                else
                    filtered:
                        filter:
                            missing:
                                field: queryCell.dbField
            when QueryOperation.unequal
                if queryCell.value?
                    bool:
                        must_not:
                            match:
                                "#{queryCell.dbField}":
                                    query: queryCell.value
                                    operator: 'and'
                else
                    bool:
                        must_not:
                            filtered:
                                filter:
                                    missing:
                                        field: queryCell.dbField
            when QueryOperation.greater
                range:
                    "#{queryCell.dbField}":
                        gt: queryCell.value
            when QueryOperation.greaterEqual
                range:
                    "#{queryCell.dbField}":
                        gte: queryCell.value
            when QueryOperation.less
                range:
                    "#{queryCell.dbField}":
                        lt: queryCell.value
            when QueryOperation.lessEqual
                range:
                    "#{queryCell.dbField}":
                        lte: queryCell.value
            when QueryOperation.contains
                bool:
                    should: ({match: {"#{queryCell.dbField}": {query: x, operator: 'and'}}} for x in queryCell.value)
            when QueryOperation.exclude
                bool:
                    minimum_should_match: queryCell.value.length
                    should: ({bool: {must_not: {match: {"#{queryCell.dbField}": {query: x, operator: 'and'}}}}} for x in queryCell.value)
            when QueryOperation.like
                bool:
                    should: [
                        {
                            match:
                                "#{queryCell.dbField}":
                                    query: queryCell.value
                                    operator: 'and'
                        }
                        {
                            regexp:
                                "#{queryCell.dbField}": '.*%s.*' % queryCell.value
                        }
                    ]
            when QueryOperation.unlike
                bool:
                    minimum_should_match: 2
                    should: [
                        {
                            bool:
                                must_not:
                                    match:
                                        "#{queryCell.dbField}":
                                            query: queryCell.value
                                            operator: 'and'
                        }
                        {
                            bool:
                                must_not:
                                    regexp:
                                        "#{queryCell.dbField}": '.*%s.*' % queryCell.value
                        }
                    ]
