config = require 'config'
elasticsearch = require 'elasticsearch'
utils = require '../lib/utils'


exports.testGetElasticsearch = (test) ->
    _elasticsearchClient = elasticsearch.Client
    elasticsearch.Client = class FakeClient
        constructor: (args) ->
            {
                @host
                @apiVersion
            } = args

    test.expect 1
    test.deepEqual utils.getElasticsearch(),
        host: config.enju.elasticsearchConfig.host
        apiVersion: config.enju.elasticsearchConfig.apiVersion
    test.done()

    elasticsearch.Client = _elasticsearchClient

exports.testGetIndexPrefix = (test) ->
    _enjuIndexPrefix = config.enju.indexPrefix
    config.enju.indexPrefix = 'index_'

    test.expect 1
    test.equal utils.getIndexPrefix(), 'index_'
    test.done()

    config.enju.indexPrefix = _enjuIndexPrefix
