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
    test.expect 2
    query = new Query(@DataModel)
    _intersect = query.intersect
    query.intersect = (field, operation) ->
        test.equal field, 'name'
        test.deepEqual operation,
            equal: 'enju'
    query.where 'name', equal: 'enju'
    query.intersect = _intersect
    test.done()

exports.testQueryWhereWillReturnSelf = (test) ->
    test.expect 1
    query = new Query(@DataModel)
    result = query.where 'name', equal: 'enju'
    test.equal result, query
    test.done()

exports.testQueryIntersectWillReturnSelf = (test) ->
    test.expect 1
    query = new Query(@DataModel)
    result = query.intersect 'name', equal: 'enju'
    test.equal result, query
    test.done()

exports.testQueryIntersectUnknownOperation = (test) ->
    test.expect 1
    query = new Query(@DataModel)
    test.throws -> query.intersect 'name', x: 'enju'
    test.done()

exports.testQueryIntersectUnknownField = (test) ->
    test.expect 1
    query = new Query(@DataModel)
    test.throws -> query.intersect 'x', equal: 'enju'
    test.done()

exports.testQueryIntersectUnequalOperation = (test) ->
    test.expect 2
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
    test.done()

exports.testQueryIntersectEqualOperation = (test) ->
    test.expect 2
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
    test.done()

exports.testQueryIntersectLessOperation = (test) ->
    test.expect 2
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
    test.done()

exports.testQueryIntersectLessEqualOperation = (test) ->
    test.expect 2
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
    test.done()

exports.testQueryIntersectGreaterOperation = (test) ->
    test.expect 2
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
    test.done()

exports.testQueryIntersectGreaterEqualOperation = (test) ->
    test.expect 2
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
    test.done()

exports.testQueryIntersectLikeOperation = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryIntersetUnlikeOperation = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryIntersectContainsOperation = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryIntersectExcludeOperation = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryIntersectReplaceDbField = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryIntersectTwoEqualOperationAndOrderOperation = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryIntersectFunctionArgument = (test) ->
    test.expect 1
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
    test.done()

exports.testQueryFetch = (test) ->
    test.expect 2
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
    query.fetch().then (result) =>
        test.deepEqual result,
            total: 1
            items: [
                id: 'id'
                version: 1
                name: 'enju'
                age: null
                createTime: null
            ]
        @DataModel._es = _es
        test.done()

exports.testQueryFirst = (test) ->
    test.expect 2
    query = new Query(@DataModel)
    _fetch = query.fetch
    query.fetch = (args) -> new Promise (resolve, reject) ->
        test.deepEqual args,
            limit: 1
            skip: 0
            fetchReference: yes
        resolve
            total: 0
            items: []
    query.first().then (result) ->
        test.equal result, null
        query.fetch = _fetch
        test.done()

exports.testQueryFirstWithoutFetchReference = (test) ->
    test.expect 2
    query = new Query(@DataModel)
    _fetch = query.fetch
    query.fetch = (args) -> new Promise (resolve, reject) ->
        test.deepEqual args,
            limit: 1
            skip: 0
            fetchReference: no
        resolve
            total: 0
            items: []
    query.first(no).then (result) ->
        test.equal result, null
        query.fetch = _fetch
        test.done()

exports.testQueryHasAny = (test) ->
    query = new Query(@DataModel)
    _es = @DataModel._es
    @DataModel._es =
        searchExists: (args) -> new Promise (resolve, reject) ->
            test.deepEqual args,
                index: 'index'
                body:
                    query:
                        match_all: {}
            resolve
                exists: yes
    query.hasAny().then (result) =>
        test.ok result
        test.expect 2
        test.done()
        @DataModel._es = _es

exports.testQueryHasAnyThrowException = (test) ->
    query = new Query(@DataModel)
    _es = @DataModel._es
    @DataModel._es =
        searchExists: (args) -> new Promise (resolve, reject) ->
            test.deepEqual args,
                index: 'index'
                body:
                    query:
                        match_all: {}
            reject
                body:
                    exists: no
    query.hasAny().then (result) =>
        test.equal result, no
        test.expect 2
        test.done()
        @DataModel._es = _es

exports.testQueryCount = (test) ->
    test.expect 2
    query = new Query(@DataModel)
    _es = @DataModel._es
    @DataModel._es =
        count: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                body:
                    query:
                        match_all: {}
                size: 0
            callback null, count: 1
    query.count().then (result) =>
        test.equal result, 1
        @DataModel._es = _es
        test.done()

exports.testQuerySum = (test) ->
    test.expect 2
    query = new Query(@DataModel)
    _es = @DataModel._es
    @DataModel._es =
        search: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                body:
                    query:
                        match_all: {}
                    aggs:
                        intraday_return:
                            sum:
                                field: 'age'
                size: 0
            callback null,
                aggregations:
                    intraday_return:
                        value: 18
    query.sum('age').then (result) =>
        test.equal result, 18
        @DataModel._es = _es
        test.done()

exports.testQueryGroupBy = (test) ->
    test.expect 2
    query = new Query(@DataModel)
    _es = @DataModel._es
    @DataModel._es =
        search: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                body:
                    query:
                        match_all: {}
                    aggs:
                        genres:
                            terms:
                                field: 'age'
                                size: 1000
                                order:
                                    _term: 'asc'
                size: 0
            callback null,
                aggregations:
                    genres:
                        buckets: [
                            doc_count: 1
                            key: 18
                        ]
    query.groupBy('age').then (result) =>
        test.deepEqual result, [doc_count: 1, key: 18]
        @DataModel._es = _es
        test.done()
