config = require 'config'
q = require 'q'

utils = require './utils'
Query = require './query'
properties = require './properties'
exceptions = require './exceptions'


module.exports = class Document
    ###
    @property _index: {string} You can set index name by this attribute.
    @property _settings: {object} You can set index settings by this attribute.
    @property id: {string}
    @property version: {number}
    @property _properties: {object} {'property_name': {Property}}
    ###
    @_properties =
        id: new properties.StringProperty(dbField: '_id')
        version: new properties.IntegerProperty(dbField: '_version')
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


    # -----------------------------------------------------
    # public methods
    # -----------------------------------------------------
    @define = ->
        ###
        1. define properties with class name.
            @param className: {string}
            @param properties: {object}
            @returns {constructor}
        2. define properties for this document.
            @param properties: {object}
        ###
        if arguments.length is 2 and typeof(arguments[0]) is 'string' and typeof(arguments[1]) is 'object'
            # 1. define properties with class name.
        else if arguments.length is 1 and typeof(arguments[0]) is 'object'
            # 2. define properties for this document.
            for key, value of arguments[0]
                @_properties[key] = value
            return
        throw exceptions.ArgumentError('Argument error for enju.Document.define()')

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
