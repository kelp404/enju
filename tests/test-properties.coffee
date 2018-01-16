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
    test.throws -> property.toJs null, Error
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

exports.testStringPropertyToDbWithNull = (test) ->
    property = new properties.StringProperty()
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, null
    test.expect 1
    test.done()

exports.testStringPropertyToDbWithNullAndDefaultValue = (test) ->
    property = new properties.StringProperty
        default: 'default'
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, 'default'
    test.equal instance.property, 'default'
    test.expect 2
    test.done()

exports.testStringPropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.StringProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testStringPropertyToDbWithoutNull = (test) ->
    property = new properties.StringProperty()
    property.propertyName = 'property'
    instance =
        property:
            toString: ->
                test.ok yes
                'string'
    result = property.toDb instance
    test.equal result, 'string'
    test.expect 2
    test.done()
