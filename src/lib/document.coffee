config = require 'config'
utils = require './utils'
Query = require './query'


module.exports = class Document
    constructor: ->

    # -----------------------------------------------------
    # private methods
    # -----------------------------------------------------
    @getIndexName = ->
        "#{utils.getIndexPrefix()}#{@_index}"
    @getProperties = ->
        if '_properties' not of @
            @_properties = do =>
                result = {}
                for key, value of @ when key and key[0] isnt '_' and typeof(@[key]) isnt 'function'
                    result[key] = value
        return @_properties


    # -----------------------------------------------------
    # public methods
    # -----------------------------------------------------
    @where = (field, operation) ->
        ###
        Generate the query for this document.
        Please via Query.intersect().
        ###
        query = new Query(@)
        query.intersect field, operation
