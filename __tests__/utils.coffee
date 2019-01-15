config = require 'config'
elasticsearch = require 'elasticsearch'
utils = require '../lib/utils'


jest.mock 'elasticsearch'

beforeEach ->
    elasticsearch.Client.mockClear()

test 'Get elasticsearch client.', ->
    elasticsearch.Client = jest.fn (args) ->
        {
            host
            apiVersion
        } = args
    expect(utils.getElasticsearch()).toMatchSnapshot()
    expect(elasticsearch.Client).toBeCalled()

test 'Get index prefix.', ->
    expect(utils.getIndexPrefix()).toBe config.enju.indexPrefix
