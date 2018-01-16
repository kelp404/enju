properties = require '../lib/properties'
exceptions = require '../lib/exceptions'


exports.testStringPropertyToJsWithNull = (test) ->
    property = new properties.StringProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testStringPropertyToJsWithNullAndDefaultValue = (test) ->
    property = new properties.StringProperty
        default: 'default'
    result = property.toJs null
    test.equal result, 'default'
    test.expect 1
    test.done()

exports.testStringPropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.StringProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error, 'property is required.'
    test.expect 1
    test.done()

exports.testStringPropertyToJsWithoutNull = (test) ->
    property = new properties.StringProperty()
    result = property.toJs
        toString: ->
            test.ok yes
            'string'
    test.equal result, 'string'
    test.expect 2
    test.done()
