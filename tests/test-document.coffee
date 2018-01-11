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
