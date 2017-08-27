config = require 'config'
utils = require '../lib/utils'


exports.testGetIndexPrefix = (test) ->
    _enjuIndexPrefix = config.enju.indexPrefix
    config.enju.indexPrefix = 'index_'

    test.expect 1
    test.equals utils.getIndexPrefix(), 'index_'
    test.done()

    config.enju.indexPrefix = _enjuIndexPrefix
