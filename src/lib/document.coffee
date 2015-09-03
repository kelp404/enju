config = require 'config'
q = require 'q'
utils = require './utils'
Query = require './query'
properties = require './properties'


module.exports = class Document
    ###
    @property _index: {string} You can set index name by this attribute.
    @property _settings: {object} You can set index settings by this attribute.
    @property _id: {string}
    @property _version: {number}
    @property _properties: {object|null} {'property_name': {Property}}
    ###
    constructor: ->

    # -----------------------------------------------------
    # private methods
    # -----------------------------------------------------
    @getIndexName = ->
        ###
        Get the index name with prefix.
        @returns: {string}
        ###
        "#{utils.getIndexPrefix()}#{@_index}"

    @getProperties = ->
        ###
        Get properties of this document.
        @returns: {object} {'property_name': {Property}}
        ###
        if '_properties' not of @
            @_properties = do =>
                result = {}
                for key, value of @ when key and key[0] isnt '_' and typeof(@[key]) isnt 'function'
                    result[key] = value
        return @_properties


    # -----------------------------------------------------
    # public methods
    # -----------------------------------------------------
    @define = (data) ->
        console.log 'add'

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
