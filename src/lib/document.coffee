config = require 'config'
utils = require './utils'


module.exports = class Document
    constructor: ->

    getIndexName: ->
        "#{utils.getIndexPrefix()}#{@_index}"
