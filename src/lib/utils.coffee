util = require 'util'
config = require 'config'
elasticsearch = require 'elasticsearch'
properties = require './properties'


module.exports =
    getElasticsearch: ->
        ###
        Get the connection for ElasticSearch.
        @returns {Elasticsearch.Client}
        ###
        new elasticsearch.Client util._extend({}, config.enju.elasticsearchConfig)

    getIndexPrefix: ->
        ###
        Get index prefix.
        @returns {string}
        ###
        config.enju.indexPrefix ? ''

    bleachRegexWords: (value = '') ->
        ###
        Let regex words not work.
        @params value {string}
        @returns {string}
        ###
        value = "#{value}"
        table = '^$*+?{}.[]()\\|/'
        result = []
        for word in value
            if word in table
                result.push "\\#{word}"
            else
                result.push word
        result.join ''

    updateReferenceProperties: (documents) -> new Promise (resolve, reject) ->
        ###
        Fetch reference properties of documents.
        @param documents {list<Document>}
        @returns {promise}  The data will direct apply on the arguments.
        ###
        if not documents or not documents.length
            return resolve()

        dataTable = {}  # {documentClassName: {documentId: {Document}}}
        documentClasses = {}  # {documentClassName: documentClass}
        referenceProperties = []  # all reference properties in documents

        # scan what kind of documents should be fetched
        for propertyName, property of documents[0].constructor._properties
            if property.constructor isnt properties.ReferenceProperty
                continue
            if property.referenceClass.name not of dataTable
                dataTable[property.referenceClass.name] = {}
                documentClasses[property.referenceClass.name] = property.referenceClass
            referenceProperties.push property

        # scan what id of documents should be fetched
        for document in documents
            for property in referenceProperties  # loop all reference properties in the document
                documentId = document[property.propertyName]
                if documentId
                    dataTable[property.referenceClass.name][documentId] = null

        # fetch documents
        tasks = []
        for documentClassName, items of dataTable
            tasks.push do (documentClassName, items) ->
                documentClasses[documentClassName].get(Object.keys(items), no).then (referenceDocuments) ->
                    for referenceDocument in referenceDocuments
                        dataTable[documentClassName][referenceDocument.id] = referenceDocument
        Promise.all(tasks).then ->
            # update reference properties of documents
            for document in documents
                for property in referenceProperties  # loop all reference properties in the document
                    resolveDocument = dataTable[property.referenceClass.name][document[property.propertyName]]
                    if property.required and not resolveDocument
                        console.log "There are a reference class can't mapping: #{property.referenceClass.name}::#{document[property.propertyName]}"
                        continue
                    document[property.propertyName] = resolveDocument
            resolve()
        .catch (error) ->
            reject error
