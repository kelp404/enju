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
        host: config.enju.elasticsearchHost,
        apiVersion: config.enju.apiVersion
      });
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
