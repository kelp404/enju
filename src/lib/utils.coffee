config = require 'config'
elasticsearch = require 'elasticsearch'


module.exports =
    getElasticsearch: ->
        ###
        Get the connection for ElasticSearch.
        @return {Elasticsearch.Client}
        ###
        new elasticsearch.Client
            host: config.enjuElasticsearchHost

    getIndexPrefix: ->
        ###
        Get index prefix.
        @return {string}
        ###
        config.enjuIndexPrefix ? ''
