config = require 'config'
elasticsearch = require 'elasticsearch'


module.exports =
    getElasticsearch: ->
        ###
        Get the connection for ElasticSearch.
        @returns {Elasticsearch.Client}
        ###
        new elasticsearch.Client
            host: config.enju.elasticsearchHost
            apiVersion: config.enju.apiVersion

    getIndexPrefix: ->
        ###
        Get index prefix.
        @returns {string}
        ###
        config.enju.indexPrefix ? ''
