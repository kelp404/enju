config = require 'config'


module.exports =
    getIndexPrefix: ->
        config.enjuIndexPrefix ? ''
