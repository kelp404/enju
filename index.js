(function() {
  var UserModel, enju, properties, user,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  exports.Document = require('./lib/document');

  properties = require('./lib/properties');

  exports.StringProperty = properties.StringProperty;

  exports.IntegerProperty = properties.IntegerProperty;

  exports.FloatProperty = properties.FloatProperty;

  exports.BooleanProperty = properties.BooleanProperty;

  exports.DateProperty = properties.DateProperty;

  exports.ListProperty = properties.ListProperty;

  exports.ObjectProperty = properties.ObjectProperty;

  exports.ReferenceProperty = properties.ReferenceProperty;

  enju = require('./');

  UserModel = (function(superClass) {
    extend(UserModel, superClass);

    function UserModel() {
      return UserModel.__super__.constructor.apply(this, arguments);
    }

    UserModel._index = 'test_users';

    UserModel._settings = {
      analysis: {
        analyzer: {
          email_url: {
            type: 'custom',
            tokenizer: 'uax_url_email'
          }
        }
      }
    };

    UserModel.define({
      name: new enju.StringProperty({
        required: true
      }),
      email: new enju.StringProperty({
        required: true,
        analyzer: 'email_url'
      })
    });

    return UserModel;

  })(enju.Document);

  user = new UserModel();

}).call(this);
