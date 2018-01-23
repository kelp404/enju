enju = require '../'
Query = require '../lib/query'

exports.setUp = (done) ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
            age: new enju.IntegerProperty()
            createTime: new enju.DateProperty
                dbField: 'create_time'
    @DataModel = DataModel
    done()

exports.testQueryWhereWillPassArgumentsToIntersect = (test) ->
    query = new Query(@DataModel)
    _intersect = query.intersect
    query.intersect = (field, operation) ->
        test.equal field, 'name'
        test.deepEqual operation,
            equal: 'enju'
    query.where 'name', equal: 'enju'
    test.expect 2
    test.done()
    query.intersect = _intersect

exports.testQueryWhereWillReturnSelf = (test) ->
    query = new Query(@DataModel)
    result = query.where 'name', equal: 'enju'
    test.equal result, query
    test.expect 1
    test.done()

exports.testQueryIntersectWillReturnSelf = (test) ->
    query = new Query(@DataModel)
    result = query.intersect 'name', equal: 'enju'
    test.equal result, query
    test.expect 1
    test.done()

exports.testQueryIntersectUnknownOperation = (test) ->
    query = new Query(@DataModel)
    test.throws -> query.intersect 'name', x: 'enju'
    test.expect 1
    test.done()

exports.testQueryIntersectUnknownField = (test) ->
    query = new Query(@DataModel)
    test.throws -> query.intersect 'x', equal: 'enju'
    test.expect 1
    test.done()

exports.testQueryIntersectUnequalOperation = (test) ->
    queryA = new Query(@DataModel)
    queryA.intersect 'name', unequal: 'enju'
    queryB = new Query(@DataModel)
    queryB.intersect 'name', '!=': 'enju'
    test.deepEqual queryA.queryCells,
        [
            dbField: 'name'
            operation: 'unequal'
            value: 'enju'
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.deepEqual queryA.queryCells, queryB.queryCells
    test.expect 2
    test.done()

exports.testQueryIntersectEqualOperation = (test) ->
    queryA = new Query(@DataModel)
    queryA.intersect 'name', equal: 'enju'
    queryB = new Query(@DataModel)
    queryB.intersect 'name', '==': 'enju'
    test.deepEqual queryA.queryCells,
        [
            dbField: 'name'
            operation: 'equal'
            value: 'enju'
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.deepEqual queryA.queryCells, queryB.queryCells
    test.expect 2
    test.done()

exports.testQueryIntersectLessOperation = (test) ->
    queryA = new Query(@DataModel)
    queryA.intersect 'age', less: 20
    queryB = new Query(@DataModel)
    queryB.intersect 'age', '<': 20
    test.deepEqual queryA.queryCells,
        [
            dbField: 'age'
            operation: 'less'
            value: 20
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.deepEqual queryA.queryCells, queryB.queryCells
    test.expect 2
    test.done()

exports.testQueryIntersectLessEqualOperation = (test) ->
    queryA = new Query(@DataModel)
    queryA.intersect 'age', lessEqual: 20
    queryB = new Query(@DataModel)
    queryB.intersect 'age', '<=': 20
    test.deepEqual queryA.queryCells,
        [
            dbField: 'age'
            operation: 'lessEqual'
            value: 20
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.deepEqual queryA.queryCells, queryB.queryCells
    test.expect 2
    test.done()

exports.testQueryIntersectGreaterOperation = (test) ->
    queryA = new Query(@DataModel)
    queryA.intersect 'age', greater: 20
    queryB = new Query(@DataModel)
    queryB.intersect 'age', '>': 20
    test.deepEqual queryA.queryCells,
        [
            dbField: 'age'
            operation: 'greater'
            value: 20
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.deepEqual queryA.queryCells, queryB.queryCells
    test.expect 2
    test.done()

exports.testQueryIntersectGreaterEqualOperation = (test) ->
    queryA = new Query(@DataModel)
    queryA.intersect 'age', greaterEqual: 20
    queryB = new Query(@DataModel)
    queryB.intersect 'age', '>=': 20
    test.deepEqual queryA.queryCells,
        [
            dbField: 'age'
            operation: 'greaterEqual'
            value: 20
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.deepEqual queryA.queryCells, queryB.queryCells
    test.expect 2
    test.done()

exports.testQueryIntersectLikeOperation = (test) ->
    query = new Query(@DataModel)
    query.intersect 'name', like: 'enju'
    test.deepEqual query.queryCells,
        [
            dbField: 'name'
            operation: 'like'
            value: 'enju'
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.expect 1
    test.done()

exports.testQueryIntersetUnlikeOperation = (test) ->
    query = new Query(@DataModel)
    query.intersect 'name', unlike: 'enju'
    test.deepEqual query.queryCells,
        [
            dbField: 'name'
            operation: 'unlike'
            value: 'enju'
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.expect 1
    test.done()

exports.testQueryIntersectContainsOperation = (test) ->
    query = new Query(@DataModel)
    query.intersect 'age', contains: [18, 20]
    test.deepEqual query.queryCells,
        [
            dbField: 'age'
            operation: 'contains'
            value: [18, 20]
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.expect 1
    test.done()

exports.testQueryIntersectExcludeOperation = (test) ->
    query = new Query(@DataModel)
    query.intersect 'age', exclude: [18, 20]
    test.deepEqual query.queryCells,
        [
            dbField: 'age'
            operation: 'exclude'
            value: [18, 20]
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.expect 1
    test.done()

exports.testQueryIntersectReplaceDbField = (test) ->
    createTime = new Date('2018-01-23T00:00:00.000Z')
    query = new Query(@DataModel)
    query.intersect 'createTime', equal: createTime
    test.deepEqual query.queryCells,
        [
            dbField: 'create_time'
            operation: 'equal'
            value: createTime
            isIntersect: yes
            isUnion: undefined
            isContainsEmpty: no
        ]
    test.expect 1
    test.done()

exports.testQueryIntersectTwoEqualOperationAndOrderOperation = (test) ->
    query = new Query(@DataModel)
    query.intersect 'name', equal: 'enju'
    query.intersect 'name', equal: 'tina'
    query.orderBy 'createTime'
    test.deepEqual query.queryCells,
        [
            {
                dbField: 'name'
                operation: 'equal'
                value: 'enju'
                isIntersect: yes
                isUnion: undefined
                isContainsEmpty: no
            }
            {
                dbField: 'name'
                operation: 'equal'
                value: 'tina'
                isIntersect: yes
                isUnion: undefined
                isContainsEmpty: no
            }
            {
                dbField: 'create_time'
                operation: 'orderASC'
                value: undefined
                isIntersect: undefined
                isUnion: undefined
                isContainsEmpty: no
            }
        ]
    test.expect 1
    test.done()

exports.testQueryIntersectFunctionArgument = (test) ->
    query = new Query(@DataModel)
    query.intersect (subQuery) ->
        subQuery.where 'name', equal: 'enju'
        .union 'name', equal: 'tina'
    test.deepEqual query.queryCells,
        [[
            {
                dbField: 'name'
                operation: 'equal'
                value: 'enju'
                isIntersect: yes
                isUnion: undefined
                isContainsEmpty: no
            }
            {
                dbField: 'name'
                operation: 'equal'
                value: 'tina'
                isIntersect: undefined
                isUnion: yes
                isContainsEmpty: no
            }
        ]]
    test.expect 1
    test.done()

exports.testQueryFetch = (test) ->
    query = new Query(@DataModel)
    query.where 'name', equal: 'enju'
    _es = @DataModel._es
    @DataModel._es =
        search: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                body:
                    query:
                        match:
                            name:
                                query: 'enju'
                                operator: 'and'
                    sort: []
                from: 0
                size: 1000
                fields: [ '_source' ]
                version: true
            callback null,
                hits:
                    hits: [
                        _id: 'id'
                        _version: 1
                        _source:
                            name: 'enju'
                    ]
                    total: 1
    query.fetch().then (result) ->
        test.deepEqual result,
            total: 1
            items: [
                id: 'id'
                version: 1
                name: 'enju'
                age: null
                createTime: null
            ]
        test.expect 2
        test.done()
        @DataModel._es = _es
