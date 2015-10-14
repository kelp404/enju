config = require 'config'
utils = require '../lib/utils'


exports.testGetIndexPrefix = (test) ->
    _enjuIndexPrefix = config.enjuIndexPrefix
    config.enjuIndexPrefix = 'index_'

    test.expect 1
    test.equals utils.getIndexPrefix(), 'index_'
    test.done()

    config.enjuIndexPrefix = _enjuIndexPrefix
