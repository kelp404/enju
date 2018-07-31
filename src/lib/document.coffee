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
    constructor: (args = {}) ->
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
            id: new properties.KeywordProperty(dbField: '_id')
            version: new properties.IntegerProperty(dbField: '_version')
        @_es = utils.getElasticsearch()

        if arguments.length is 2 and typeof(arguments[0]) is 'string' and arguments[1]? and typeof(arguments[1]) is 'object'
            # 1. define properties with class name.
            defined = arguments[1]
            defined._type ?= arguments[0]
            class DynamicClass extends @
                @define defined
            return DynamicClass
        else if arguments.length is 1 and arguments[0]? and typeof(arguments[0]) is 'object'
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

    @get = (ids, fetchReference=yes) -> new Promise (resolve, reject) =>
        ###
        Fetch the document with id or ids.
        If the document is not exist, it will return null.
        @param ids {string|list}
        @param fetchReference {bool} Fetch reference data of this document.
        @returns {promise} (Document|null|list)
        ###
        # the empty document
        if not ids? or ids is ''
            return resolve(null)
        # empty documents
        if ids.constructor is Array
            ids = (x for x in ids when x)
            if ids.length is 0
                return resolve([])

        # fetch documents
        if ids.constructor is Array
            @_es.mget
                index: @getIndexName()
                type: @getDocumentType()
                body:
                    ids: ids
            , (error, response) =>
                return reject(error) if error
                result = []
                for doc in response.docs when doc.found
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
                        resolve result
                    .catch (error) ->
                        reject error
                else
                    resolve result
            return

        # fetch the document
        @_es.get
            index: @getIndexName()
            type: @getDocumentType()
            id: ids
        , (error, response) =>
            if error
                if error.status is 404
                    return resolve(null)
                return reject(error)
            args =
                id: response._id
                version: response._version
            for propertyName, property of @_properties
                dbField = property.dbField ? propertyName
                if dbField of response._source
                    args[propertyName] = response._source[dbField]

            # call resolve()
            document = new @(args)
            if fetchReference
                Query.updateReferenceProperties([document]).then ->
                    resolve document
                .catch (error) ->
                    reject error
            else
                resolve document

    @exists = (id) -> new Promise (resolve, reject) =>
        ###
        Is the document exists?
        @param id {string} The documents' id.
        @returns {promise<bool>}
        ###
        @_es.exists
            index: @getIndexName()
            type: @getDocumentType()
            id: id
        , (error, response) ->
            return reject(error) if error
            resolve(response)


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

    @refresh = (args = {}) -> new Promise (resolve, reject) =>
        ###
        Explicitly refresh one or more index, making all operations performed since the last refresh available for search.
        https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/api-reference-5-6.html#api-indices-refresh-5-6
        @params args {object}
        @returns {promise}
        ###
        args.index = @getIndexName()
        @_es.indices.refresh args, (error) ->
            return reject(error) if error
            resolve()

    @updateMapping = ->
        ###
        Update the index mapping.
        https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
        https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
        @returns {promise}
        ###
        createIndex = => new Promise (resolve, reject) =>
            @_es.indices.create
                index: @getIndexName()
            , (error, response) ->
                if error and error.status isnt 400
                    return reject(error)
                setTimeout ->
                    resolve response
                , 1000

        closeIndex = => new Promise (resolve, reject) =>
            @_es.indices.close
                index: @getIndexName()
            , (error, response) ->
                return reject(error) if error
                resolve response

        putSettings = => new Promise (resolve, reject) =>
            if not @_settings
                return resolve()
            @_es.indices.putSettings
                index: @getIndexName()
                body:
                    settings:
                        index: @_settings
            , (error, response) ->
                return reject(error) if error
                resolve response

        putMapping = => new Promise (resolve, reject) =>
            mapping = {}
            for propertyName, property of @_properties
                if property.dbField in ['_id', '_version']
                    # don't set the mapping to _id and _version
                    continue
                if property.mapping
                    # there is an object in this field
                    mapping[property.dbField ? propertyName] =
                        properties: property.mapping
                    continue

                field = {}
                switch property.constructor
                    when properties.StringProperty
                        field.type = 'string'
                    when properties.TextProperty
                        field.type = 'text'
                    when properties.KeywordProperty
                        field.type = 'keyword'
                    when properties.BooleanProperty
                        field.type = 'boolean'
                    when properties.IntegerProperty
                        field.type = 'long'
                    when properties.FloatProperty
                        field.type = 'double'
                    when properties.DateProperty
                        field.type = 'date'
                        field.format = 'strict_date_optional_time||epoch_millis'
                    when properties.ReferenceProperty
                        field.type = 'keyword'
                    when properties.ListProperty
                        switch property.itemClass
                            when properties.StringProperty
                                field.type = 'string'
                            when properties.TextProperty
                                field.type = 'text'
                            when properties.KeywordProperty
                                field.type = 'keyword'
                            when properties.BooleanProperty
                                field.type = 'boolean'
                            when properties.IntegerProperty
                                field.type = 'long'
                            when properties.FloatProperty
                                field.type = 'double'
                            when properties.DateProperty
                                field.type = 'date'
                                field.format = 'strict_date_optional_time||epoch_millis'
                            when properties.ReferenceProperty
                                field.type = 'keyword'

                if property.type
                    field.type = property.type
                if property.analyzer
                    field.analyzer = property.analyzer
                if property.normalizer
                    field.normalizer = property.normalizer
                if property.index?
                    field.index = property.index

                if Object.keys(field).length
                    mapping[property.dbField ? propertyName] = field

            @_es.indices.putMapping
                index: @getIndexName()
                type: @getDocumentType()
                body:
                    properties: mapping
            , (error, response) ->
                return reject(error) if error
                resolve response

        openIndex = => new Promise (resolve, reject) =>
            @_es.indices.open
                index: @getIndexName()
            , (error, response) ->
                return reject(error) if error
                resolve response

        createIndex()
        .then closeIndex
        .then putSettings
        .then putMapping
        .then openIndex
        .then =>
            console.log "updated mapping [#{@getIndexName()}]"
        .catch (error) ->
            console.error error
            throw error

    save: (refresh=no) -> new Promise (resolve, reject) =>
        ###
        Save this document.
        @param refresh {bool} Refresh the index after performing the operation.
        @returns {promise<Document>}
        ###
        document = {}  # it will be written to database
        convertError = null
        for propertyName, property of @constructor._properties when property.dbField not in ['_id', '_version']
            dbFieldName = property.dbField ? propertyName
            try
                document[dbFieldName] = property.toDb @
            catch error
                convertError = error
        return reject(convertError) if convertError?

        if @id
            # modify
            args =
                index: @constructor.getIndexName()
                type: @constructor.getDocumentType()
                refresh: refresh
                id: @id
                version: if @version? then @version + 1 else 0
                versionType: 'external'
                body: document
        else
            # create
            args =
                index: @constructor.getIndexName()
                type: @constructor.getDocumentType()
                refresh: refresh
                body: document

        @constructor._es.index args, (error, response) =>
            return reject(error) if error
            @id = response._id
            @version = response._version
            resolve @

    delete: (refresh=no) -> new Promise (resolve, reject) =>
        ###
        Delete this document.
        @returns {promise<Document>}
        ###
        @constructor._es.delete
            index: @constructor.getIndexName()
            type: @constructor.getDocumentType()
            refresh: refresh
            id: @id
        , (error) =>
            return reject(error) if error
            resolve @
