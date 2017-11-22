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
