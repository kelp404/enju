config = require 'config'
elasticsearch = require 'elasticsearch'
utils = require '../lib/utils'
enju = require '../'


beforeEach ->
    jest.mock 'elasticsearch'
afterEach ->
    jest.restoreAllMocks()

test 'Get elasticsearch client.', ->
    jest.spyOn(elasticsearch, 'Client').mockImplementation (args) ->
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
    jest.spyOn(UserModel, 'get').mockImplementation (ids) -> new Promise (resolve) ->
        resolve [
            new UserModel
                id: 'AWiYXbY_SjjuUM2b1CGI'
                name: 'enju'
        ]
    article = new ArticleModel
        user: 'AWiYXbY_SjjuUM2b1CGI'
    utils.updateReferenceProperties([article]).then ->
        expect(UserModel.get).toBeCalledWith ['AWiYXbY_SjjuUM2b1CGI'], no
        expect(article).toMatchSnapshot()
