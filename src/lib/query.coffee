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
        {@dbField, @operation, @value, @isIntersect, @isUnion} = args
        # if there is a query like .where('field', contains: []) it will be true.
        @isContainsEmpty = @operation is QueryOperation.contains and not @value.length


module.exports = class Query
    constructor: (documentClass, queryCells=[]) ->
        ###
        @param documentClass {constructor} The document's constructor.
        ###
        @documentClass = documentClass
        @queryCells = queryCells


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
        refactorQueryCells = ->
            ###
            If the last query cell is union query cell, then we append the intersect query cell.
            We should let previous query cells be the sub query, the append this query cell.
            ###
            queryCells = []
            for index in [@queryCells..0] by -1
                queryCells.unshift @queryCells[index].pop()
                break if @queryCells[index].isIntersect
            @queryCells.push queryCells

        if typeof(field) is 'function'
            # .where (query) ->
            subQuery = field(new Query(@documentClass))
            @queryCells.push subQuery.queryCells
        else
            # .where Document.name, '==': 'Enju'
            allFields = []
            for propertyName, property of @documentClass._properties
                allFields.push propertyName
                allFields.push(property.dbField) if property.dbField
            if typeof(field) is 'string' and field.split('.', 1)[0] not in allFields
                throw new exceptions.SyntaxError("#{field} not in #{@documentClass.name}")

            previousQueryCell = if @queryCells.length then @queryCells[@queryCells.length - 1] else null
            if previousQueryCell and previousQueryCell.constructor isnt Array and previousQueryCell.isUnion
                refactorQueryCells()

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
                isIntersect: yes
        @

    union: (field, operation) ->
        ###
        Append a query as intersect.
        @param field {Property|string}
            Property: The property of the document.
            string: The property name of the document.
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
        if not @queryCells.length
            throw new exceptions.SyntaxError('Can not use .union() at the first query.')
        allFields = []
        for propertyName, property of @documentClass._properties
            allFields.push propertyName
            allFields.push(property.dbField) if property.dbField
        if typeof(field) is 'string' and field.split('.', 1)[0] not in allFields
            throw new exceptions.SyntaxError("#{field} not in #{@documentClass.name}")

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
            isUnion: yes
        @

    orderBy: (field, descending=no) ->
        ###
        Append the order query.
        @param member: {Property|string} The property name of the document.
        @param descending: {bool} Is sorted by descending?
        @returns {Query}
        ###
        allFields = []
        for propertyName, property of @documentClass._properties
            allFields.push propertyName
            allFields.push(property.dbField) if property.dbField
        if typeof(field) is 'string' and field.split('.', 1)[0] not in allFields
            throw new exceptions.SyntaxError("#{field} not in #{@documentClass.name}")

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
        queries = []
        sort = []
        isContainsEmpty = no

        for queryCell in @queryCells
            if queryCell.constructor is Array
                # there are sub queries at this query
                subQuery = new Query(@documentClass, queryCell)
                elasticsearchQuery = subQuery.compileQueries()
                if elasticsearchQuery.isContainsEmpty
                    continue
                queries.push elasticsearchQuery.query
                continue

            # compile query cell to elasticsearch query object and append into queries
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
                    queries.push @compileQuery queryCell

        result =
            sort: sort
        # append queries
        if isContainsEmpty
            result.isContainsEmpty = yes
        else if queries.length is 0
            result.query =
                match_all: {}
        else if queries.length is 1
            result.query = queries[0]
        else
            result.query =
                bool:
                    should: queries
            minimumMatch = yes
            for index in [@queryCells.length - 1..0] by -1
                if @queryCells[index].constructor isnt Array and @queryCells[index].isUnion
                    minimumMatch = no
                    break
            result.query.bool.minimum_should_match = queries.length if minimumMatch
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
