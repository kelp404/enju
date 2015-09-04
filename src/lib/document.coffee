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
    @property _es: {Elasticsearch.Client}
    @property _className: {string}
    ###
    @_properties =
        id: new properties.StringProperty(dbField: '_id')
        version: new properties.IntegerProperty(dbField: '_version')
    @_es = utils.getElasticsearch()
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

    @updateMapping = ->
        ###
        Update the index mapping.
        https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
        https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
        ###
        createIndex = =>
            deferred = q.defer()
            @_es.indices.create
                index: @getIndexName()
            , (error, response) ->
                if error and error.status isnt '400'
                    deferred.reject error
                    return
                setTimeout ->
                    deferred.resolve response
                , 1000
            deferred.promise

        closeIndex = =>
            deferred = q.defer()
            @_es.indices.close
                index: @getIndexName()
            , (error, response) ->
                if error
                    deferred.reject error
                    return
                deferred.resolve response
            deferred.promise

        putSettings = =>
            deferred = q.defer()
            if not @_settings
                deferred.resolve()
                return deferred.promise
            @_es.indices.putSettings
                index: @getIndexName()
                body:
                    settings:
                        index: @_settings
            , (error, response) ->
                if error
                    deferred.reject error
                    return
                deferred.resolve response
            deferred.promise

        putMapping = =>
            deferred = q.defer()
            mapping = {}
            for name, property of @_properties
                if property.dbField in ['_id', '_version']
                    # don't set the mapping to _id and _version
                    continue
                if property.mapping
                    # there is an object in this field
                    mapping[name] =
                        properties: property.mapping
                    continue

                field = {}
                switch property.constructor
                    when properties.StringProperty
                        field['type'] = 'string'
                    when properties.BooleanProperty
                        field['type'] = 'boolean'
                    when properties.IntegerProperty
                        field['type'] = 'long'
                    when properties.FloatProperty
                        field['type'] = 'double'
                    when properties.DateProperty
                        field['type'] = 'date'
                        field['format'] = 'dateOptionalTime'
                    when properties.ReferenceProperty
                        field['type'] = 'string'
                        field['analyzer'] = 'keyword'
                    when properties.ListProperty
                        switch property.itemClass
                            when properties.StringProperty
                                field['type'] = 'string'
                            when properties.BooleanProperty
                                field['type'] = 'boolean'
                            when properties.IntegerProperty
                                field['type'] = 'long'
                            when properties.FloatProperty
                                field['type'] = 'double'
                            when properties.DateProperty
                                field['type'] = 'date'
                                field['format'] = 'dateOptionalTime'
                            when properties.ReferenceProperty
                                field['type'] = 'string'
                                field['analyzer'] = 'keyword'

                if property.analyzer
                    field['analyzer'] = property.analyzer

                if Object.keys(field).length
                    mapping[name] = field
            @_es.indices.putMapping
                index: @getIndexName()
                type: @_className ? @name
                body:
                    properties: mapping
            , (error, response) ->
                if error
                    deferred.reject error
                    return
                deferred.resolve response
            deferred.promise

        openIndex = =>
            deferred = q.defer()
            @_es.indices.open
                index: @getIndexName()
            , (error, response) ->
                if error
                    deferred.reject error
                    return
                deferred.resolve response
            deferred.promise

        createIndex()
        .then closeIndex
        .then putSettings
        .then putMapping
        .then openIndex
        .then =>
            console.log "updated mapping [#{@getIndexName()}]"
        , (error) ->
            console.error error
            throw error

