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
