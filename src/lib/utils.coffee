util = require 'util'
config = require 'config'
elasticsearch = require 'elasticsearch'


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
