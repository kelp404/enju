(function() {
  var config, elasticsearch, util;

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

      /*
      Get index prefix.
      @returns {string}
       */
      var ref;
      return (ref = config.enju.indexPrefix) != null ? ref : '';
    }
  };

}).call(this);
