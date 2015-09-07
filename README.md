# enju

An elasticsearch client on node.js written in CoffeeScript.

![tina](_enju.gif)



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
ProductModel.where('title', '==': 'enju').fetch().then (products, total) ->
    console.log JSON.stringify(products, null, 4)
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
_index: {string} You can set index name by this attribute.
_type: {string} You can set type of the document. The default is class name.
_settings: {object} You can set index settings by this attribute.
id: {string}
version: {number}
```

**Class method**
>```coffee
@get = (ids, fetchReference=yes) ->
    ###
    Fetch the document with id or ids.
    If the document is not exist, it will return null.
    @param ids: {string|list}
    @param fetchReference: {bool} Fetch reference data of this document.
    @returns {promise} (Document|null|list)
    ###
# ex: Document.get('MQ-ULRSJ291RG_eEwSfQ').then (document) ->
# ex: Document.get(['MQ-ULRSJ291RG_eEwSfQ']).then (documents) ->
```
```coffee
@all = ->
    ###
    Generate a query for this document.
    @returns {Query}
    ###
# ex: query = Document.all()
```



[MIT License](http://opensource.org/licenses/mit-license.php)
