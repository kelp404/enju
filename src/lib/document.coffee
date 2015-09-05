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
    constructor: (args={}) ->
        for propertyName, property of @constructor._properties
            @[propertyName] = property.toJs args[propertyName]


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
            for propertyName, property of arguments[0]
                property.propertyName = propertyName
                @_properties[propertyName] = property
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

        # fetch documents

        # fetch the document
        @_es.get
            index: @getIndexName()
            type: @name
            id: ids
        , (error, response) =>
            if error
                deferred.reject error
                return
            args = response._source
            args.id = response._id
            args.version = response._version
            deferred.resolve(new @(args))

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
        @returns {promise}
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
            for propertyName, property of @_properties
                if property.dbField in ['_id', '_version']
                    # don't set the mapping to _id and _version
                    continue
                if property.mapping
                    # there is an object in this field
                    mapping[propertyName] =
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
                    mapping[propertyName] = field
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

        deferred = q.defer()
        createIndex()
        .then closeIndex
        .then putSettings
        .then putMapping
        .then openIndex
        .then =>
            console.log "updated mapping [#{@getIndexName()}]"
            deferred.resolve()
        , (error) ->
            console.error error
            deferred.reject error

        deferred.promise

    save: (refresh=no) ->
        ###
        Save the document.
        @param refresh: {bool} Refresh the index after performing the operation.
        @returns {promise} (Document)
        ###
        deferred = q.defer()
        if not @version?
            # fix version
            @version = 0

        document = {}  # it will be written to database
        for propertyName, property of @constructor._properties when property.dbField not in ['_id', '_version']
            dbFieldName = property.dbField ? propertyName
            try
                document[dbFieldName] = property.toDb @
            catch error
                deferred.reject error
                return deferred.promise

        @constructor._es.index
            index: @constructor.getIndexName()
            type: @constructor.name
            refresh: refresh
            id: @id
            version: @version
            body: document
        , (error, response) =>
            if error
                deferred.reject error
                return
            @id = response._id
            @version = response._version
            deferred.resolve @

        deferred.promise
