config = require 'config'
q = requre 'q'
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
    @get = (ids, fetchReference=yes) ->
        ###
        Fetch the document with id or ids.
        If the document is not exist, it will return null.
        @param ids: {string|list}
        @param fetchReference: {bool} Fetch reference data of this document.
        @returns {promise} (Document|null|list)
        ###
        deferred = q.defer()

        # the empty document
        if not ids? or ids is ''
            deferred.resolve null
            return deferred.promise
        # empty documents
        if ids.constructor is Array and ids.length is 0
            deferred.resolve []
            return deferred.promise

        es = utils.getElasticsearch()
        # fetch documents

        # fetch the document
        es.get
            index: @constructor.getIndexName()
            type: @constructor.name
            id: ids
        , (error, response) ->

        deferred.promise

    @where = (field, operation) ->
        ###
        Generate the query for this document.
        Please via Query.intersect().
        ###
        query = new Query(@)
        query.intersect field, operation
