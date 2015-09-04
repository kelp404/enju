(function() {
  var config, elasticsearch;

  config = require('config');

  elasticsearch = require('elasticsearch');

  module.exports = {
    getElasticsearch: function() {

      /*
      Get the connection for ElasticSearch.
      @return {Elasticsearch.Client}
       */
      return new elasticsearch.Client({
        host: config.enjuElasticsearchHost
      });
    },
    getIndexPrefix: function() {

      /*
      Get index prefix.
      @return {string}
       */
      var ref;
      return (ref = config.enjuIndexPrefix) != null ? ref : '';
    }
  };

}).call(this);
