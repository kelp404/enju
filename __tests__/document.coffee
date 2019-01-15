config = require 'config'
enju = require '../'
utils = require '../lib/utils'
Query = require '../lib/query'


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
    Query.updateReferenceProperties.mockClear?()
    utils.getIndexPrefix.mockClear?()

test 'Get the index prefix of the model.', ->
    utils.getIndexPrefix = jest.fn -> config.enju.indexPrefix
    result = DataModel.getIndexName()
    expect(result).toBe "#{config.enju.indexPrefix}index"
    expect(utils.getIndexPrefix).toBeCalled()

test 'Get the type of the model.', ->
    class DataModelA extends enju.Document
        @_index = 'index'
    class DataModelB extends enju.Document
        @_type = 'DataModel'
        @_index = 'index'
    expect(DataModelA.getDocumentType()).toBe 'DataModelA'
    expect(DataModelB.getDocumentType()).toBe 'DataModel'

test 'Model.get() will return null without query id.', ->
    Promise.all [
        DataModel.get('').then (result) -> expect(result).toBeNull()
        DataModel.get(null).then (result) -> expect(result).toBeNull()
        DataModel.get(undefined ).then (result) -> expect(result).toBeNull()
        DataModel.get([]).then (result) -> expect(result).toEqual []
    ]

test 'Get the document by id without reference.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.get = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            _id: 'id'
            _version: 0
            _source:
                name: 'enju'
    DataModel.get('id', no).then (document) ->
        expect(document).toMatchSnapshot()

test 'Get the document by id with reference.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.get = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            _id: 'id'
            _version: 0
            _source:
                name: 'enju'
    Query.updateReferenceProperties = jest.fn (documents) -> new Promise (resolve) ->
        expect(documents).toMatchSnapshot()
        resolve()
    DataModel.get('id').then ->
        expect(Query.updateReferenceProperties).toBeCalled()

test 'Get documents by ids without reference.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.mget = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            docs: [
                found: yes
                _id: 'id'
                _version: 0
                _source:
                    name: 'enju'
            ]
    DataModel.get(['id'], no).then (documents) ->
        expect(documents).toMatchSnapshot()

test 'Get documents by ids with reference.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.mget = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            docs: [
                found: yes
                _id: 'id'
                _version: 0
                _source:
                    name: 'enju'
            ]
    Query.updateReferenceProperties = jest.fn (documents) -> new Promise (resolve) ->
        expect(documents).toMatchSnapshot()
        resolve()
    DataModel.get(['id']).then ->
        expect(Query.updateReferenceProperties).toBeCalled()

test 'Is the document exists.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.exists = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null, yes
    DataModel.exists('id').then (result) ->
        expect(result).toBe yes

test 'Generate a query of the model.', ->
    query = DataModel.all()
    expect(query).toMatchSnapshot()

test 'Refresh the model.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.indices.refresh = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null, yes
    DataModel.refresh().then ->
        expect(DataModel._es.indices.refresh).toBeCalled()

test 'Generate a query via where().', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    query = DataModel.where 'name', equal: 'enju'
    expect(query).toMatchSnapshot()

test 'Save a document without refresh.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.index = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            _id: 'id'
            _version: 0
    data = new DataModel
        name: 'enju'
    data.save().then (result) ->
        expect(result).toMatchSnapshot()
        expect(DataModel._es.index).toBeCalled()

test 'Save a document with refresh.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.index = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null,
            _id: 'id'
            _version: 0
    data = new DataModel
        name: 'enju'
    data.save(yes).then (result) ->
        expect(result).toMatchSnapshot()
        expect(DataModel._es.index).toBeCalled()

test 'Delete the document without refresh.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.delete = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    data = new DataModel
        id: 'id'
        name: 'enju'
    data.delete().then ->
        expect(DataModel._es.delete).toBeCalled()

test 'Delete the document with refresh.', ->
    class DataModel extends enju.Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    DataModel._es.delete = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    data = new DataModel
        id: 'id'
        name: 'enju'
    data.delete(yes).then ->
        expect(DataModel._es.delete).toBeCalled()
