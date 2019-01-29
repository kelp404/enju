config = require 'config'
elasticsearch = require 'elasticsearch'
utils = require '../lib/utils'
enju = require '../'


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

test 'Bleach regex words.', ->
    result = utils.bleachRegexWords '^$*+?{}.[]()\\hello|/'
    expect(result).toMatchSnapshot()

test 'Fetch the reference property of the document.', ->
    class UserModel extends enju.Document
        @_index = 'users'
        @define
            name: new enju.StringProperty()
    class ArticleModel extends enju.Document
        @_index = 'articles'
        @define
            content: new enju.StringProperty()
            user: new enju.ReferenceProperty
                referenceClass: UserModel
    UserModel.get = jest.fn (ids) -> new Promise (resolve) ->
        expect(ids).toEqual ['AWiYXbY_SjjuUM2b1CGI']
        resolve [
            new UserModel
                id: 'AWiYXbY_SjjuUM2b1CGI'
                name: 'enju'
        ]
    article = new ArticleModel
        user: 'AWiYXbY_SjjuUM2b1CGI'
    utils.updateReferenceProperties([article]).then ->
        expect(UserModel.get).toBeCalled()
        expect(article).toMatchSnapshot()
