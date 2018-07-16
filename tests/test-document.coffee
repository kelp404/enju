q = require 'q'
enju = require '../'
Document = require '../lib/document'
Query = require '../lib/query'
utils = require '../lib/utils'


exports.testDocumentGetIndexName = (test) ->
    _utilsGetIndexPrefix = utils.getIndexPrefix
    utils.getIndexPrefix = -> 'prefix_'

    class DataModel extends Document
        @_index = 'index'
    test.expect 1
    test.equal DataModel.getIndexName(), 'prefix_index'
    test.done()

    utils.getIndexPrefix = _utilsGetIndexPrefix

exports.testDocumentGetDocumentType = (test) ->
    class DataModelA extends Document
        @_index = 'index'
    class DataModelB extends Document
        @_type = 'DataModel'
        @_index = 'index'
    test.expect 2
    test.equal DataModelA.getDocumentType(), 'DataModelA'
    test.equal DataModelB.getDocumentType(), 'DataModel'
    test.done()

exports.testDocumentGetWithNull = (test) ->
    class DataModel extends Document
        @_index = 'index'
    test.expect 5
    tasks = []
    tasks.push DataModel.get('').then (result) ->
        test.equal result, null
    tasks.push DataModel.get(null).then (result) ->
        test.equal result, null
    tasks.push DataModel.get(undefined).then (result) ->
        test.equal result, null
    tasks.push DataModel.get([]).then (result) ->
        test.equal result.constructor, Array
        test.equal result.length, 0
    q.all(tasks).then ->
        test.done()

exports.testDocumentGetWithIdButNotFetchReference = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    DataModel._es =
        get: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                id: 'id'
            callback null,
                _id: 'id'
                _version: 0
                _source:
                    name: 'enju'

    test.expect 2
    DataModel.get('id', no).then (document) ->
        test.equal document.name, 'enju'
        test.done()
        DataModel._es = _es

exports.testDocumentGetWithIdAndFetchReference = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    _updateReferenceProperties = Query.updateReferenceProperties
    DataModel._es =
        get: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                id: 'id'
            callback null,
                _id: 'id'
                _version: 0
                _source:
                    name: 'enju'

    test.expect 2
    Query.updateReferenceProperties = (documents) ->
        deferred = q.defer()
        test.deepEqual documents, [{
            id: 'id'
            version: 0
            name: 'enju'
        }]
        test.done()
        DataModel._es = _es
        Query.updateReferenceProperties = _updateReferenceProperties
        deferred.resolve()
        deferred.promise
    DataModel.get('id')

exports.testDocumentGetWithIdsButNotFetchReference = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    DataModel._es =
        mget: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                body:
                    ids: ['id']
            callback null,
                docs: [
                    found: yes
                    _id: 'id'
                    _version: 0
                    _source:
                        name: 'enju'
                ]

    test.expect 2
    DataModel.get(['id'], no).then (documents) ->
        test.deepEqual documents, [
            id: 'id'
            version: 0
            name: 'enju'
        ]
        test.done()
        DataModel._es = _es

exports.testDocumentGetWithIdsAndFetchReference = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    _updateReferenceProperties = Query.updateReferenceProperties
    DataModel._es =
        mget: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                body:
                    ids: ['id']
            callback null,
                docs: [
                    found: yes
                    _id: 'id'
                    _version: 0
                    _source:
                        name: 'enju'
                ]

    test.expect 2
    Query.updateReferenceProperties = (documents) ->
        deferred = q.defer()
        test.deepEqual documents, [{
            id: 'id'
            version: 0
            name: 'enju'
        }]
        test.done()
        DataModel._es = _es
        Query.updateReferenceProperties = _updateReferenceProperties
        deferred.resolve()
        deferred.promise
    DataModel.get(['id'])

exports.testDocumentExists = (test) ->
    class DataModel extends Document
        @_index = 'index'
    _es = DataModel._es
    DataModel._es =
        exists: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                id: 'id'
            callback null, yes

    test.expect 2
    DataModel.exists('id').then (result) ->
        test.ok result
        test.done()
    DataModel._es = _es

exports.testDocumentAll = (test) ->
    class DataModel extends Document
        @_index = 'index'
    query = DataModel.all()
    test.expect 2
    test.equal query.constructor, Query
    test.equal query.documentClass, DataModel
    test.done()

exports.testDocumentRefresh = (test) ->
    class DataModel extends Document
        @_index = 'index'
    _es = DataModel._es
    DataModel._es =
        indices:
            refresh: (args, callback) ->
                test.deepEqual args,
                    index: 'index'
                callback null, yes

    test.expect 2
    DataModel.refresh().then ->
        test.ok 1
        test.done()
    DataModel._es = _es

exports.testDocumentWhere = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    query = DataModel.where 'name', equal: 'enju'
    test.expect 2
    test.equal query.constructor, Query
    test.deepEqual query.queryCells, [
        dbField: 'name'
        operation: 'equal'
        value: 'enju'
        isIntersect: yes
        isUnion: undefined
        isContainsEmpty: no
    ]
    test.done()

exports.testDocumentSaveWithoutRefresh = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    DataModel._es =
        index: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                refresh: no
                id: null,
                version: 0
                versionType: 'external'
                body:
                    name: 'enju'
            callback null,
                _id: 'id'
                _version: 0

    test.expect 3
    data = new DataModel
        name: 'enju'
    data.save().then (result) ->
        test.equal result.id, 'id'
        test.equal result.version, 0
        test.done()
        DataModel._es = _es

exports.testDocumentSaveWithRefresh = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    DataModel._es =
        index: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                refresh: yes
                id: null,
                version: 0
                versionType: 'external'
                body:
                    name: 'enju'
            callback null,
                _id: 'id'
                _version: 0

    test.expect 3
    data = new DataModel
        name: 'enju'
    data.save(yes).then (result) ->
        test.equal result.id, 'id'
        test.equal result.version, 0
        test.done()
        DataModel._es = _es

exports.testDocumentDeleteWithoutRefresh = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    DataModel._es =
        delete: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                refresh: no
                id: 'id',
            callback null

    test.expect 1
    data = new DataModel
        id: 'id'
        name: 'enju'
    data.delete().then ->
        test.done()
        DataModel._es = _es

exports.testDocumentDeleteWithRefresh = (test) ->
    class DataModel extends Document
        @_index = 'index'
        @define
            name: new enju.StringProperty()
    _es = DataModel._es
    DataModel._es =
        delete: (args, callback) ->
            test.deepEqual args,
                index: 'index'
                type: 'DataModel'
                refresh: yes
                id: 'id',
            callback null

    test.expect 1
    data = new DataModel
        id: 'id'
        name: 'enju'
    data.delete(yes).then ->
        test.done()
        DataModel._es = _es
