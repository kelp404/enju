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


#UserModel.updateMapping()
#.then ->
#    console.log 'success'

#user = new UserModel
#    name: 'Kelp'
#    email: 'kelp@phate.org'
#user.save().then (user) ->
#    console.log user

UserModel.get('AU-f6Pw3SByHNzSJXm22')
.then (user) ->
    console.log user
, (error) ->
    console.log error


#{ _index: 'test_users',
#  _type: 'UserModel',
#  _id: 'AU-dgutLZbrIxICNGvk-',
#  _version: 1,
#  found: true,
#  _source: { name: 'Kelp', email: 'kelp@phate.org' } }
