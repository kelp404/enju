(function() {
  var Document, config, utils;

  config = require('config');

  utils = require('./utils');

  module.exports = Document = (function() {
    function Document() {}

    Document.prototype.getIndexName = function() {
      return "" + (utils.getIndexPrefix()) + this._index;
    };

    return Document;

  })();

}).call(this);
