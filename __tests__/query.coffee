enju = require '../'
Query = require '../lib/query'
exceptions = require '../lib/exceptions'


DataModel = null
generateDataModel = ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
            age: new enju.IntegerProperty()
            createTime: new enju.DateProperty
                dbField: 'create_time'

beforeEach ->
    DataModel = generateDataModel()

test 'Test query where will pass arguments to intersect.', ->
    query = new Query(DataModel)
    query.intersect = jest.fn -> null
    query.where 'name', equal: 'enju'
    expect(query.intersect).toBeCalledWith 'name',
        equal: 'enju'

test 'Test query where will return self.', ->
    query = new Query(DataModel)
    result = query.where 'name', equal: 'enju'
    expect(result).toBe query

test 'Test query intersect will return self.', ->
    query = new Query(DataModel)
    result = query.intersect 'name', equal: 'enju'
    expect(result).toBe query

test 'Test query intersect unknown operation.', ->
    query = new Query(DataModel)
    func = ->
        query.intersect 'name', x: 'enju'
    expect(func).toThrow exceptions.OperationError

test 'Test query intersect unknown field.', ->
    query = new Query(DataModel)
    func = ->
        query.intersect 'x', equal: 'enju'
    expect(func).toThrow exceptions.SyntaxError

test 'Test query intersect unequal operation.', ->
    queryA = new Query(DataModel)
    queryA.intersect 'name', unequal: 'enju'
    queryB = new Query(DataModel)
    queryB.intersect 'name', '!=': 'enju'
    expect(queryA).toEqual queryB
    expect(queryA).toMatchSnapshot()

test 'Test query intersect equal operation.', ->
    queryA = new Query(DataModel)
    queryA.intersect 'name', equal: 'enju'
    queryB = new Query(DataModel)
    queryB.intersect 'name', '==': 'enju'
    expect(queryA).toEqual queryB
    expect(queryA).toMatchSnapshot()

test 'Test query intersect less operation.', ->
    queryA = new Query(DataModel)
    queryA.intersect 'age', less: 20
    queryB = new Query(DataModel)
    queryB.intersect 'age', '<': 20
    expect(queryA).toEqual queryB
    expect(queryA).toMatchSnapshot()

test 'Test query intersect less equal operation.', ->
    queryA = new Query(DataModel)
    queryA.intersect 'age', lessEqual: 20
    queryB = new Query(DataModel)
    queryB.intersect 'age', '<=': 20
    expect(queryA).toEqual queryB
    expect(queryA).toMatchSnapshot()

test 'Test query intersect greater operation.', ->
    queryA = new Query(DataModel)
    queryA.intersect 'age', greater: 20
    queryB = new Query(DataModel)
    queryB.intersect 'age', '>': 20
    expect(queryA).toEqual queryB
    expect(queryA).toMatchSnapshot()

test 'Test query intersect greater equal operation.', ->
    queryA = new Query(DataModel)
    queryA.intersect 'age', greaterEqual: 20
    queryB = new Query(DataModel)
    queryB.intersect 'age', '>=': 20
    expect(queryA).toEqual queryB
    expect(queryA).toMatchSnapshot()

test 'Test query intersect like operation.', ->
    query = new Query(DataModel)
    query.intersect 'name', like: 'enju'
    expect(query).toMatchSnapshot()

test 'Test query intersect unlike operation.', ->
    query = new Query(DataModel)
    query.intersect 'name', unlike: 'enju'
    expect(query).toMatchSnapshot()

test 'Test query intersect contains operation.', ->
    query = new Query(DataModel)
    query.intersect 'age', contains: [18, 20]
    expect(query).toMatchSnapshot()

test 'Test query intersect exclude operation.', ->
    query = new Query(DataModel)
    query.intersect 'age', exclude: [18, 20]
    expect(query).toMatchSnapshot()

test 'Test query intersect replace db field.', ->
    query = new Query(DataModel)
    query.intersect 'createTime', equal: new Date('2018-01-23T00:00:00.000Z')
    expect(query.queryCells).toMatchSnapshot()

test 'Test query intersect two equal operation and order operation.', ->
    query = new Query(DataModel)
    query.intersect 'name', equal: 'enju'
    query.intersect 'name', equal: 'tina'
    query.orderBy 'createTime'
    expect(query.queryCells).toMatchSnapshot()

test 'Test query intersect function argument.', ->
    query = new Query(DataModel)
    query.intersect (subQuery) ->
        subQuery.where 'name', equal: 'enju'
        .union 'name', equal: 'tina'
    expect(query.queryCells).toMatchSnapshot()

test 'Test query fetch.', ->
    query = new Query(DataModel)
    query.where 'name', equal: 'enju'
    DataModel._es.search = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
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
        expect(result).toMatchSnapshot()
    expect(DataModel._es.search).toBeCalled()

test 'Test query first.', ->
    query = new Query(DataModel)
    query.fetch = (args) -> new Promise (resolve) ->
        expect(args).toMatchSnapshot()
        resolve
            total: 0
            items: []
    query.first().then (result) ->
        expect(result).toBeNull()

test 'Test query first without fetch reference.', ->
    query = new Query(DataModel)
    query.fetch = (args) -> new Promise (resolve) ->
        expect(args).toMatchSnapshot()
        resolve
            total: 0
            items: []
    query.first(no).then (result) ->
        expect(result).toMatchSnapshot()

test 'Test query has any.', ->
    query = new Query(DataModel)
    DataModel._es.searchExists = jest.fn (args) -> new Promise (resolve) ->
        expect(args).toMatchSnapshot()
        resolve
            exists: yes
    query.hasAny().then (result) ->
        expect(result).toBe yes
        expect(DataModel._es.searchExists).toBeCalled()

test 'Test query count.', ->
    query = new Query(DataModel)
    DataModel._es.count = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null, count: 1
    query.count().then (result) ->
        expect(result).toBe 1

test 'Test query sum.', ->
    query = new Query(DataModel)
    DataModel._es.search = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            aggregations:
                intraday_return:
                    value: 18
    query.sum('age').then (result) ->
        expect(result).toBe 18

test 'Test query group by.', ->
    query = new Query(DataModel)
    DataModel._es.search = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            aggregations:
                genres:
                    buckets: [
                        doc_count: 1
                        key: 18
                    ]
    query.groupBy('age').then (result) ->
        expect(result).toMatchSnapshot()
