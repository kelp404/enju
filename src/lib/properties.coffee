exports.Property = class Property

exports.StringProperty = class StringProperty extends Property
    constructor: ->
        console.log 'init string'
exports.NumberProperty = class NumberProperty extends Property
    constructor: ->
        console.log 'init number'
