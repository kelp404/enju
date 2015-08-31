(function() {
  var config;

  config = require('config');

  module.exports = {
    getIndexPrefix: function() {
      var ref;
      return (ref = config.enjuIndexPrefix) != null ? ref : '';
    }
  };

}).call(this);
