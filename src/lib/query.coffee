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

    @intersection = 'intersection'
    @union = 'union'

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
            else
                throw new exceptions.OperationError("There is no [#{value}] operation.")


class QueryCell
    constructor: (args) ->
        {@dbField, @operation, @value, @subQueries} = args

module.exports = class Query
    constructor: (documentClass) ->
        ###
        @param documentClass {constructor} The document's constructor.
        ###
        @isContainsEmpty = no  # if there is a query like .where('field', contains: []) it will be true.
        @documentClass = documentClass
        @items = []


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
        ###
        if typeof(field) is 'function'
            # .where (query) ->

        else
            # .where Document.name, '==': 'Enju'
            operation = null
            value = null
            for operation, value of operation
                break
            dbField = if typeof(field) is 'string' then field else field.dbField ? field.propertyName
            @items.push new QueryCell
                dbField: dbField
                operation: QueryOperation.convertOperation operation
                value: value
        @

    union: (field, operation) ->
        ###
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
        ###
        @

    fetch: (args={}) ->
        ###
        Fetch documents by this query.
        @param args: {object}
            limit: {number} The size of the pagination. (The limit of the result items.) default is 1000
            skip: {number} The offset of the pagination. (Skip x items.) default is 0
            fetchReference: {bool} Fetch documents of reference properties. default is true.
        @returns {promise} (object)
            items: [Document, ...]
            total: {number}
        ###
        args.limit ?= 1000
        args.skip ?= 0
        args.fetchReference ?= yes
