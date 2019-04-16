config = require 'config'
enju = require '../'
utils = require '../lib/utils'
Query = require '../lib/query'
exceptions = require '../lib/exceptions'


DataModel = null
generateDataModel = ->
    class DataModel extends enju.Document
        @_index = 'index'
        @_settings =
            analysis:
                normalizer:
                    lowercase_filter:
                        type: 'custom'
                        filter: ['lowercase']
        @define
            name: new enju.StringProperty()
            isAdmin: new enju.BooleanProperty
                default: no
                dbField: 'is_admin'
            score: new enju.FloatProperty()
            age: new enju.IntegerProperty()
            createTime: new enju.DateProperty
                dbField: 'create_time'

beforeEach ->
    DataModel = generateDataModel()
afterEach ->
    jest.restoreAllMocks()

test 'Define model.', ->
    class DataModelA extends enju.Document
        @_index = 'index'
        @_settings =
            analysis:
                normalizer:
                    lowercase_filter:
                        type: 'custom'
                        filter: ['lowercase']
        @define
            name: new enju.StringProperty()
    DataModelB = enju.Document.define 'DataModelB',
        name: new enju.StringProperty()
    expect(DataModelA).toMatchSnapshot()
    expect(DataModelA._properties).toMatchSnapshot()
    expect(DataModelA._settings).toMatchSnapshot()
    expect(DataModelB).toMatchSnapshot()
    expect(DataModelB._properties).toMatchSnapshot()

test 'Get error when define the model with wrong arguments.', ->
    func = ->
        class DataModel extends enju.Document
            @_index = 'index'
            @define {}, {}
    expect(func).toThrow exceptions.ArgumentError

test 'Update the model mapping.', ->
    DataModel._es.indices.create = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    DataModel._es.indices.close = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    DataModel._es.indices.putSettings = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    DataModel._es.indices.putMapping = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    DataModel._es.indices.open = jest.fn (args, callback) ->
        expect(args).toMatchSnapshot()
        callback null
    DataModel.updateMapping().then ->
        expect(DataModel._es.indices.create).toBeCalled()
        expect(DataModel._es.indices.close).toBeCalled()
        expect(DataModel._es.indices.putSettings).toBeCalled()
        expect(DataModel._es.indices.putMapping).toBeCalled()
        expect(DataModel._es.indices.open).toBeCalled()

test 'Get the index prefix of the model.', ->
    jest.spyOn(utils, 'getIndexPrefix').mockImplementation -> config.enju.indexPrefix
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
    jest.spyOn(utils, 'updateReferenceProperties').mockImplementation (documents) -> new Promise (resolve) ->
        expect(documents).toMatchSnapshot()
        resolve()
    DataModel.get('id').then ->
        expect(utils.updateReferenceProperties).toBeCalled()

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
    jest.spyOn(utils, 'updateReferenceProperties').mockImplementation (documents) -> new Promise (resolve) ->
        expect(documents).toMatchSnapshot()
        resolve()
    DataModel.get(['id']).then ->
        expect(utils.updateReferenceProperties).toBeCalled()

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
