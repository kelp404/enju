config = require 'config'
utils = require '../lib/utils'


exports.testGetIndexPrefix = (test) ->
    _enjuIndexPrefix = config.enjuIndexPrefix
    config.enjuIndexPrefix = 'index_'

    test.equals 'index_', utils.getIndexPrefix()
    test.done()

    config.enjuIndexPrefix = _enjuIndexPrefix
