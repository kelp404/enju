config = require 'config'
elasticsearch = require 'elasticsearch'


module.exports =
    getElasticsearch: ->
        ###
        Get the connection for ElasticSearch.
        @returns {Elasticsearch.Client}
        ###
        new elasticsearch.Client
            host: config.enjuElasticsearchHost

    getIndexPrefix: ->
        ###
        Get index prefix.
        @returns {string}
        ###
        config.enjuIndexPrefix ? ''
