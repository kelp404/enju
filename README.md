# enju ![circle-ci](https://circleci.com/gh/kelp404/enju.png?circle-token=55c92edca67c45f7e79d9d9bc6ffce340a462878) 
![npm version](https://badge.fury.io/js/enju.svg)

An elasticsearch client on node.js written in CoffeeScript.  
[tina](https://github.com/kelp404/tina) is the Python version.

![tina](_enju.gif)



## Installation
>
```bash
$ npm install enju --save
```



## Config
>
enju use [node-config](https://github.com/lorenwest/node-config).  
`/your_project/config/default.cson`
```cson
enjuElasticsearchHost: 'http://localhost:9200'
enjuIndexPrefix: ''
```



## Quick start
>
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
        name: new enju.StringProperty
            required: yes
        email: new enju.StringProperty
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
        title: new enju.StringProperty
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



## Document
>
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
        name: new enju.StringProperty
            required: yes
        email: new enju.StringProperty
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
    name: new enju.StringProperty({
        required: true
    }),
    email: new enju.StringProperty({
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
>```coffee
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
>```coffee
@get = (ids, fetchReference=yes) ->
    ###
    Fetch the document with id or ids.
    If the document is not exist, it will return null.
    @param ids {string|list}
    @param fetchReference {bool} Fetch reference data of this document.
    @returns {promise} ({items: {Document}, total: {number})
    ###
# ex: Document.get('MQ-ULRSJ291RG_eEwSfQ').then (result) ->
# ex: Document.get(['MQ-ULRSJ291RG_eEwSfQ']).then (result) ->
```
```coffee
@exists = (id) ->
    ###
    Is the document exists?
    @param id {string} The documents' id.
    @returns {promise} (bool)
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
@updateMapping = ->
    ###
    Update the index mapping.
    https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
    https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-put-mapping.html
    @returns {promise}
    ###
```

**Method**
>```coffee
save: (refresh=no) ->
    ###
    Save this document.
    @param refresh {bool} Refresh the index after performing the operation.
    @returns {promise} (Document)
    ###
```
```coffee
delete: (refresh=no) ->
    ###
    Delete this document.
    @returns {promise} (Document)
    ###
```



## Property
>
```coffee
class Property
    ###
    @property default {bool}
    @property required {bool}
    @property dbField {string}
    @property analyzer {string}
    @property mapping {object}
    @property propertyName {string} The property name in the document. It will be set at Document.define()
    ###
```
```coffee
class StringProperty extends Property
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
>
The enju query.

**Methods**
>```coffee
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
    @param member {Property|string} The property name of the document.
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
    @returns {promise} ({items: {Document}, total: {number})
    ###
```
```coffee
first: (fetchReference=yes) ->
    ###
    Fetch the first document by this query.
    @param fetchReference {bool}
    @returns {promise} ({Document|null})
    ###
```
```
hasAny: ->
    ###
    Are there any documents match with the query?
    @returns {promise} (bool)
    ###
```
```coffee
count: ->
    ###
    Count documents by the query.
    @returns {promise} ({number})
    ###
```



## Example
>```sql
select * from "ExampleModel" where "name" = "tina"
```
```coffee
ExampleModel.where('name', equal: 'tina').fetch().then (result) ->
```

---
>```sql
select * from "ExampleModel" where "name" = "tina" and "email" = "kelp@phate.org"
```
```coffee
ExampleModel.where('name', equal: 'enju')
    .where('email', equal='kelp@phate.org')
    .fetch().then (result) ->
```

---
>```sql
select * from "ExampleModel" where "name" like "%tina%" or "email" like "%tina%"
```
```coffee
ExampleModel.where (query) ->
    query.where('name', like: 'tina').union('email', like: 'tina')
.fetch().then (result) ->
```

---
>```sql
select * from "ExampleModel" where "category" = 1 or "category" = 3
    order by "created_at" limit 20 offset 20
```
```coffee
ExampleModel.where('category', contains: [1, 3])
    .orderBy('created_at')
    .fetch(20, 20).then (result) ->
```

---
>Fetch the first item.
```sql
select * from "ExampleModel" where "age" >= 10
     order by "created_at" desc limit 1
```
```coffee
ExampleModel.where('age', '>=': 10)
    .orderBy('created_at', yes).first().then (model) ->
```

---
>Count items.
```sql
select count(*) from "ExampleModel" where "age" < 10
```
```python
ExampleModel.where('age', less: 10).count().then (result) ->
```



[MIT License](http://opensource.org/licenses/mit-license.php)
