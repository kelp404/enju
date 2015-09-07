exports.Document = require './lib/document'

properties = require './lib/properties'
exports.StringProperty = properties.StringProperty
exports.IntegerProperty = properties.IntegerProperty
exports.FloatProperty = properties.FloatProperty
exports.BooleanProperty = properties.BooleanProperty
exports.DateProperty = properties.DateProperty
exports.ListProperty = properties.ListProperty
exports.ObjectProperty = properties.ObjectProperty
exports.ReferenceProperty = properties.ReferenceProperty

exceptions = require './lib/exceptions'
exports.ArgumentError = exceptions.ArgumentError
exports.ValueRequiredError = exceptions.ValueRequiredError
exports.TypeError = exceptions.TypeError
exports.OperationError = exceptions.OperationError
exports.SyntaxError = exceptions.SyntaxError




enju = require './'
class UserModel extends enju.Document
    @_index = 'test_users'
    @_settings =
        analysis:
            analyzer:
                email_url:
                    type: 'custom'
                    tokenizer: 'uax_url_email'
    @define
        name: new enju.StringProperty
            required: yes
        email: new enju.StringProperty
            required: yes
            analyzer: 'email_url'
        createTime: new enju.DateProperty
            autoNow: yes
            dbField: 'create_time'

class ProductModel extends enju.Document
    @_index = 'test_products'
    @define
        user: new enju.ReferenceProperty
            referenceClass: UserModel
            required: yes
        title: new enju.StringProperty
            required: yes
        createTime: new enju.DateProperty
            autoNow: yes
            dbField: 'create_time'

#UserModel = enju.Document.define 'UserModel',
#    _index: 'test_users'
#    _settings:
#        analysis:
#            analyzer:
#                email_url:
#                    type: 'custom'
#                    tokenizer: 'uax_url_email'
#    name: new enju.StringProperty
#        required: yes
#    email: new enju.StringProperty
#        required: yes
#        analyzer: 'email_url'

#user = new UserModel
#    name: 'Kelp'
#    email: 'kelp@phate.org'
#user.save().then (user) ->
#    console.log user

#UserModel.get('AU-f6Pw3SByHNzSJXm22')
#.then (user) ->
#    console.log user
#, (error) ->
#    console.log error

#query = UserModel.all()
#query.fetch()
#.then (result) ->
#    console.log result
#.catch (error) ->
#    console.log error

#ProductModel.all().fetch()
#.then (products) ->
#    console.log products

ProductModel.get('AU-mAh1-trhIjlPeQBbM').then (product) ->
    console.log product

#{ _index: 'test_users',
#  _type: 'UserModel',
#  _id: 'AU-dgutLZbrIxICNGvk-',
#  _version: 1,
#  found: true,
#  _source: { name: 'Kelp', email: 'kelp@phate.org' } }
