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

    @all = 'all'


class QueryCell
    constructor: (@operation, @field, @value, @subQueries) ->


module.exports = class Query
    constructor: (documentClass) ->
        @isContainsEmpty = no
        @documentClass = documentClass
        @items = [
            QueryCell(QueryOperation.all)
        ]

    intersect: (field, operation) ->
        @
