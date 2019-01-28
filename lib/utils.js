(function() {
  var config, elasticsearch, util,
    indexOf = [].indexOf;

  util = require('util');

  config = require('config');

  elasticsearch = require('elasticsearch');

  module.exports = {
    getElasticsearch: function() {
      /*
      Get the connection for ElasticSearch.
      @returns {Elasticsearch.Client}
      */
      return new elasticsearch.Client(util._extend({}, config.enju.elasticsearchConfig));
    },
    getIndexPrefix: function() {
      var ref;
      /*
      Get index prefix.
      @returns {string}
      */
      return (ref = config.enju.indexPrefix) != null ? ref : '';
    },
    bleachRegexWords: function(value = '') {
      var i, len, result, table, word;
      value = `${value}`;
      table = '^$*+?{}.[]()\\|/';
      result = [];
      for (i = 0, len = value.length; i < len; i++) {
        word = value[i];
        if (indexOf.call(table, word) >= 0) {
          result.push(`\\${word}`);
        } else {
          result.push(word);
        }
      }
      return result.join('');
    }
  };

}).call(this);
