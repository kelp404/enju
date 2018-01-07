Document = require '../lib/document'
utils = require '../lib/utils'


exports.testDocumentGetIndexName = (test) ->
    _utilsGetIndexPrefix = utils.getIndexPrefix
    utils.getIndexPrefix = -> 'prefix_'

    class DataModel extends Document
        @_index = 'index'
    test.expect 1
    test.equals DataModel.getIndexName(), 'prefix_index'
    test.done()

    utils.getIndexPrefix = _utilsGetIndexPrefix

exports.testDocumentGetDocumentType = (test) ->
    class DataModelA extends Document
        @_index = 'index'
    class DataModelB extends Document
        @_type = 'DataModel'
        @_index = 'index'
    test.expect 2
    test.equals DataModelA.getDocumentType(), 'DataModelA'
    test.equals DataModelB.getDocumentType(), 'DataModel'
    test.done()
