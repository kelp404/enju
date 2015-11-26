(function() {
  var config, elasticsearch;

  config = require('config');

  elasticsearch = require('elasticsearch');

  module.exports = {
    getElasticsearch: function() {

      /*
      Get the connection for ElasticSearch.
      @returns {Elasticsearch.Client}
       */
      return new elasticsearch.Client({
        host: config.enjuElasticsearchHost
      });
    },
    getIndexPrefix: function() {

      /*
      Get index prefix.
      @returns {string}
       */
      var ref;
      return (ref = config.enjuIndexPrefix) != null ? ref : '';
    }
  };

}).call(this);
