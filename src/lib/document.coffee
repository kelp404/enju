config = require 'config'
q = require 'q'

utils = require './utils'
Query = require './query'
properties = require './properties'
exceptions = require './exceptions'


module.exports = class Document
    ###
    You have to call define() to define your document.
    @property _index {string} You can set index name by this attribute.
    @property _type {string} You can set type of the document. The default is class name.
    @property _settings {object} You can set index settings by this attribute.
    @property id {string}
    @property version {number}
    @property _properties {object} {'propertyName': {Property}}
    @property _es {Elasticsearch.Client}
    ###
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

    @getDocumentType = ->
        ###
        Get the document type.
        @returns {string}
        ###
        @_type ? @name


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
        @_properties =
            id: new properties.StringProperty(dbField: '_id')
            version: new properties.IntegerProperty(dbField: '_version')
        @_es = utils.getElasticsearch()

        if arguments.length is 2 and typeof(arguments[0]) is 'string' and typeof(arguments[1]) is 'object'
            # 1. define properties with class name.
            defined = arguments[1]
            defined._type ?= arguments[0]
            class DynamicClass extends @
                @define defined
            return DynamicClass
        else if arguments.length is 1 and typeof(arguments[0]) is 'object'
            # 2. define properties for this document.
            defined = arguments[0]
            if '_index' of defined
                @_index = defined._index
                delete defined._index
            if '_settings' of defined
                @_settings = defined._settings
                delete defined._settings
            if '_type' of defined
                @_type = defined._type
                delete defined._type
            for propertyName, property of defined
                property.propertyName = propertyName
                @_properties[propertyName] = property
            return
        throw exceptions.ArgumentError('Argument error for enju.Document.define()')

    @get = (ids, fetchReference=yes) ->
        ###
        Fetch the document with id or ids.
        If the document is not exist, it will return null.
        @param ids {string|list}
        @param fetchReference {bool} Fetch reference data of this document.
        @returns {promise} (Document|null|list)
        ###
        deferred = q.defer()

        # the empty document
        if not ids? or ids is ''
            deferred.resolve null
            return deferred.promise
        # empty documents
        if ids.constructor is Array
            ids = (x for x in ids when x)
            if ids.length is 0
                deferred.resolve []
                return deferred.promise

        # fetch documents
        if ids.constructor is Array
            @_es.mget
                index: @getIndexName()
                type: @getDocumentType()
                body:
                    ids: ids
            , (error, response) =>
                if error
                    deferred.reject error
                    return
                result = []
                for doc in response.docs
                    item =
                        id: doc._id
                        version: doc._version
                    for propertyName, property of @_properties
                        dbField = property.dbField ? propertyName
                        if dbField of doc._source
                            item[propertyName] = doc._source[dbField]
                    result.push new @(item)

                # call resolve()
                if fetchReference
                    Query.updateReferenceProperties(result).then ->
                        deferred.resolve result
                else
                    deferred.resolve result
            return deferred.promise

        # fetch the document
        @_es.get
            index: @getIndexName()
            type: @getDocumentType()
            id: ids
        , (error, response) =>
            if error
                if error.status is '404'
                    deferred.resolve null
                    return
                deferred.reject error
                return
            args = response._source
            args.id = response._id
            args.version = response._version

            # call resolve()
            document = new @(args)
            if fetchReference
                Query.updateReferenceProperties([document]).then ->
                    deferred.resolve document
            else
                deferred.resolve document

        deferred.promise

    @exists = (id) ->
        ###
        Is the document exists?
        @param id {string} The documents' id.
        @returns {promise} (bool)
        ###
        deferred = q.defer()

        @_es.exists
            index: @getIndexName()
            type: @getDocumentType()
            id: id
        , (error, response) ->
            if error
                deferred.reject error
                return
            deferred.resolve response

        deferred.promise


    @all = ->
        ###
        Generate a query for this document.
        @returns {Query}
        ###
        new Query(@)

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

                if property.type
                    field['type'] = property.type
                if property.analyzer
                    field['analyzer'] = property.analyzer

                if Object.keys(field).length
                    mapping[property.dbField ? propertyName] = field
            @_es.indices.putMapping
                index: @getIndexName()
                type: @getDocumentType()
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
        Save this document.
        @param refresh {bool} Refresh the index after performing the operation.
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
            type: @constructor.getDocumentType()
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

    delete: (refresh=no) ->
        ###
        Delete this document.
        @returns {promise} (Document)
        ###
        deferred = q.defer()

        @constructor._es.delete
            index: @constructor.getIndexName()
            type: @constructor.getDocumentType()
            refresh: refresh
            id: @id
        , (error) =>
            if error
                deferred.reject error
                return
            deferred.resolve @

        deferred.promise
