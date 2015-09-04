exports.Document = require './lib/document'

properties = require './lib/properties'
exports.Property = properties.Property
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
    @define
        name: new enju.StringProperty(default: 'x')

user = new UserModel()
#console.log UserModel._properties
UserModel.updateMapping()