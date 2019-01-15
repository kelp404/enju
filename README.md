# enju
[![npm version](https://badge.fury.io/js/enju.svg)](https://www.npmjs.com/package/enju)
[![Coverage Status](https://coveralls.io/repos/github/kelp404/enju/badge.svg)](https://coveralls.io/github/kelp404/enju)
[![circle-ci](https://circleci.com/gh/kelp404/enju.svg?style=svg&circle-token=55c92edca67c45f7e79d9d9bc6ffce340a462878)](https://circleci.com/gh/kelp404/enju)
  

An elasticsearch client on node.js written in CoffeeScript.  
[tina](https://github.com/kelp404/tina) is the Python version.


  enju  |  Elasticsearch
:-----:|:-------------:
   2.x   |        2.4
   5.x   |        5.6

![tina](_enju.gif)



## Installation
```bash
$ npm install enju --save
```



## Config
enju use [node-config](https://github.com/lorenwest/node-config).  
`/your_project/config/default.json`  
Read more elasticsearch config at here:  
[https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/configuration.html](https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/configuration.html)
```json
{
    "enju": {
        "indexPrefix": "",
        "elasticsearchConfig": {
            "apiVersion": "5.6",
            "host": "http://localhost:9200"
        }
    }
}
```



## Quick start
### 1. Define models
```coffee
enju = require 'enju'
class UserModel extends enju.Document
    @_index = 'users'  # your index name
    @_settings =
        analysis:
            analyzer:
                email_url:
                    type: 'custom'
                    tokenizer: 'uax_url_email'
    @define
        name: new enju.KeywordProperty
            required: yes
        email: new enju.TextProperty
            required: yes
            analyzer: 'email_url'
        createTime: new enju.DateProperty
            autoNow: yes
            dbField: 'create_time'
class ProductModel extends enju.Document
    @_index = 'products'
    @define
        user: new enju.ReferenceProperty
            referenceClass: UserModel
            required: yes
        title: new enju.KeywordProperty
            required: yes
```
### 2. Update elasticsearch mapping
```coffee
UserModel.updateMapping()
ProductModel.updateMapping()
```
### 3. Insert documents
```coffee
user = new UserModel
    name: 'Kelp'
    email: 'kelp@phate.org'
user.save().then (user) ->
    product = new ProductModel
        user: user
        title: 'enju'
    product.save()
```
### 4. Fetch documents
```coffee
ProductModel.where('title', '==': 'enju').fetch().then (result) ->
    console.log JSON.stringify(result.items, null, 4)
    # [{
    #     "id": "AU-mMiIwtrhIjlPeQBbT",
    #     "version": 1,
    #     "user": {
    #         "id": "AU-mMiIOtrhIjlPeQBbS",
    #         "version": 1,
    #         "name": "Kelp",
    #         "email": "kelp@phate.org",
    #         "createTime": "2015-09-07T05:05:47.500Z"
    #     },
    #     "title": "enju"
    # }]
```



## Develop
```bash
# install dependencies
npm install -g nodeunit
npm install -g grunt-cli
npm install
```

```bash
# compile and watch
grunt dev
```

```bash
# build CoffeeScript
npm run build
```

```bash
# run test
npm run build
npm test
```



## Document
```coffee
# CoffeeScript
enju = require 'enju'
class UserModel extends enju.Document
    @_index = 'users'  # your index name
    @_settings =
        analysis:
            analyzer:
                email_url:
                    type: 'custom'
                    tokenizer: 'uax_url_email'
    @define
        name: new enju.KeywordProperty
            required: yes
        email: new enju.TextProperty
            required: yes
            analyzer: 'email_url'
        createTime: new enju.DateProperty
            autoNow: yes
            dbField: 'create_time'
```
```js
// JavaScript
var enju = require('enju');
var UserModel = enju.Document.define('UserModel', {
    _index: 'users',
    _settings: {
        analysis: {
            analyzer: {
                email_url: {
                    type: 'custom',
                    tokenizer: 'uax_url_email'
                }
            }
        }
    },
    name: new enju.KeywordProperty({
        required: true
    }),
    email: new enju.TextProperty({
        required: true,
        analyzer: 'email_url'
    }),
    createTime: new enju.DateProperty({
        autoNow: true,
        dbField: 'create_time'
    })
});
```

**Properties**
```coffee
class Document
    ###
    _index {string} You can set index name by this attribute. **constructor property**
    _type {string} You can set type of the document. The default is class name. **constructor property**
    _settings {object} You can set index settings by this attribute. **constructor property**
    id {string}
    version {number}
    ###
```

**Class method**
```coffee
@get = (ids, fetchReference=yes) ->
    ###
    Fetch the document with id or ids.
    If the document is not exist, it will return null.
    @param ids {string|list}
    @param fetchReference {bool} Fetch reference data of this document.
    @returns {promise<Document>}
    ###
# ex: Document.get('MQ-ULRSJ291RG_eEwSfQ').then (result) ->
# ex: Document.get(['MQ-ULRSJ291RG_eEwSfQ']).then (result) ->
```
```coffee
@exists = (id) ->
    ###
    Is the document exists?
    @param id {string} The documents' id.
    @returns {promise<bool>}
    ###
```
```coffee
@all = ->
    ###
    Generate a query for this document.
    @returns {Query}
    ###
# ex: query = Document.all()
```
```coffee
@where = (field, operation) ->
    ###
    Generate the query for this document.
    @param field {Property|string|function}
        Property: The property of the document.
        string: The property name of the document.
        function: The sub query.
    @param operation {object}
        key: [
            '!=', 'unequal'
            '==', 'equal'
            '<', 'less'
            '<=', 'lessEqual'
            '>', 'greater',
            '>=', 'greaterEqual'
            'like'
            'unlike'
            'contains'
            'exclude'
        ]
    @returns {Query}
    ###
# ex: query = Document.where('field', '==': 'value')
```
```coffee
@refresh = (args) ->
    ###
    Explicitly refresh one or more index.
    https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/api-reference-5-6.html#api-indices-refresh-5-6
    @params args {object}
    @returns {promise}
    ###
```
```coffee
@updateMapping = ->
    ###
    Update the index mapping.
    https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
    https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
    @returns {promise}
    ###
```

**Method**
```coffee
save: (refresh=no) ->
    ###
    Save this document.
    @param refresh {bool} Refresh the index after performing the operation.
    @returns {promise<Document>}
    ###
```
```coffee
delete: (refresh=no) ->
    ###
    Delete this document.
    @returns {promise<Document>}
    ###
```



## Property
```coffee
class Property
    ###
    @property default {any}
    @property required {bool}
    @property dbField {string}
    @property type {string}  https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping-types.html
    @property index {bool}  https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping-index.html
    @property mapping {object}  https://www.elastic.co/guide/en/elasticsearch/reference/5.6/mapping.html
    @property propertyName {string} The property name in the document. It will be set at Document.define()
    ###
```
```coffee
class StringProperty extends Property
    ###
    https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analyzer.html
    @property analyzer {string}
    ###
```
```coffee
class TextProperty extends Property
    ###
    https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analyzer.html
    @property analyzer {string}
    ###
```
```coffee
class KeywordProperty extends Property
    ###
    https://www.elastic.co/guide/en/elasticsearch/reference/5.6/analysis-normalizers.html
    @property normalizer {string}
    ###
```
```coffee
class IntegerProperty extends Property
```
```coffee
class FloatProperty extends Property
```
```coffee
class BooleanProperty extends Property
```
```coffee
class DateProperty extends Property
    ###
    @property autoNow {bool}
    ###
```
```coffee
class ListProperty extends Property
    ###
    @property itemClass {constructor}
    ###
```
```coffee
class ObjectProperty extends Property
```
```coffee
class ReferenceProperty extends Property
    ###
    @property referenceClass {Property}
    ###
```



## Query
The enju query.

**Methods**
```coffee
where: (field, operation) ->
    ###
    Append a query as intersect.
    @param field {Property|string|function}
        Property: The property of the document.
        string: The property name of the document.
        function: The sub query.
    @param operation {object}
        key: [
            '!=', 'unequal'
            '==', 'equal'
            '<', 'less'
            '<=', 'lessEqual'
            '>', 'greater',
            '>=', 'greaterEqual'
            'like'
            'unlike'
            'contains'
            'exclude'
        ]
    @returns {Query}
    ###
```
```coffee
union: (field, operation) ->
    ###
    Append a query as intersect.
    @param field {Property|string}
        Property: The property of the document.
        string: The property name of the document.
    @param operation {object}
        key: [
            '!=', 'unequal'
            '==', 'equal'
            '<', 'less'
            '<=', 'lessEqual'
            '>', 'greater',
            '>=', 'greaterEqual'
            'like'
            'unlike'
            'contains'
            'exclude'
        ]
    @returns {Query}
    ###
```
```coffee
orderBy: (field, descending=no) ->
    ###
    Append the order query.
    @param field {Property|string} The property name of the document.
    @param descending {bool} Is sorted by descending?
    @returns {Query}
    ###
```
```coffee
fetch: (args={}) ->
    ###
    Fetch documents by this query.
    @param args {object}
        limit: {number} The size of the pagination. (The limit of the result items.) default is 1000
        skip: {number} The offset of the pagination. (Skip x items.) default is 0
        fetchReference: {bool} Fetch documents of reference properties. default is true.
    @returns {promise<object>} ({items: {Document}, total: {number}})
    ###
```
```coffee
first: (fetchReference=yes) ->
    ###
    Fetch the first document by this query.
    @param fetchReference {bool}
    @returns {promise<Document|null>}
    ###
```
```coffee
count: ->
    ###
    Count documents by the query.
    @returns {promise<number>}
    ###
```
```coffee
sum: (field) ->
    ###
    Sum the field of documents by the query.
    https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-sum-aggregation.html
    @param field {Property|string} The property name of the document.
    @returns {promise<number>}
    ###
```
```coffee
groupBy: (field, args) ->
    ###
    @param field {Property|string} The property name of the document.
    @param args {object}
        limit: {number}  Default is 1,000.
        order: {string} "count|term"  Default is "term".
        descending: {bool}  Default is no.
    @returns {promise<list<object>>}
        [{
            doc_count: {number}
            key: {string}
        }]
    ###
```



## Example
```sql
select * from "ExampleModel" where "name" = "tina"
```
```coffee
ExampleModel.where('name', equal: 'tina').fetch().then (result) ->
```

---
```sql
select * from "ExampleModel" where "name" = "tina" and "email" = "kelp@phate.org"
```
```coffee
ExampleModel.where('name', equal: 'enju')
    .where('email', equal: 'kelp@phate.org')
    .fetch().then (result) ->
```

---
```sql
select * from "ExampleModel" where "name" like "%tina%" or "email" like "%tina%"
```
```coffee
ExampleModel.where (query) ->
    query.where('name', like: 'tina').union('email', like: 'tina')
.fetch().then (result) ->
```

---
```sql
select * from "ExampleModel" where "category" = 1 or "category" = 3
    order by "created_at" limit 20 offset 20
```
```coffee
ExampleModel.where('category', contains: [1, 3])
    .orderBy('created_at')
    .fetch(20, 20).then (result) ->
```

---
Fetch the first item.
```sql
select * from "ExampleModel" where "age" >= 10
     order by "created_at" desc limit 1
```
```coffee
ExampleModel.where('age', '>=': 10)
    .orderBy('created_at', yes).first().then (model) ->
```

---
Count items.
```sql
select count(*) from "ExampleModel" where "age" < 10
```
```coffee
ExampleModel.where('age', less: 10).count().then (result) ->
```

