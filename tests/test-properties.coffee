properties = require '../lib/properties'
exceptions = require '../lib/exceptions'


exports.testProperty = (test) ->
    property = new properties.StringProperty
        required: yes
        dbField: 'field'
        type: 'string'
        index: 'index'
        analyzer: 'keyword'
        mapping:
            analyzer: 'keyword'
        default: 'default'
    test.deepEqual property,
        required: yes
        dbField: 'field'
        type: 'string'
        index: 'index'
        analyzer: 'keyword'
        mapping:
            analyzer: 'keyword'
        defaultValue: 'default'
    test.expect 1
    test.done()

exports.testPropertyDefaultRequiredValue = (test) ->
    property = new properties.StringProperty()
    test.equal property.required, no
    test.expect 1
    test.done()

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

exports.testIntegerPropertyToJsWithNull = (test) ->
    property = new properties.IntegerProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testIntegerPropertyToJsWithNullAndDefaultValue = (test) ->
    property = new properties.IntegerProperty
        default: 2
    result = property.toJs null
    test.equal result, 2
    test.expect 1
    test.done()

exports.testIntegerPropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.IntegerProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testIntegerPropertyToJsWithoutNull = (test) ->
    _parseInt = global.parseInt
    property = new properties.IntegerProperty()
    global.parseInt = (value) ->
        test.equal value, 3
        value
    result = property.toJs 3
    test.equal result, 3
    test.expect 2
    test.done()
    global.parseInt = _parseInt

exports.testIntegerPropertyToDbWithNull = (test) ->
    property = new properties.IntegerProperty()
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, null
    test.expect 1
    test.done()

exports.testIntegerPropertyToDbWithNullAndDefaultValue = (test) ->
    property = new properties.IntegerProperty
        default: 2
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, 2
    test.equal instance.property, 2
    test.expect 2
    test.done()

exports.testIntegerPropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.IntegerProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testIntegerPropertyToDbWithoutNull = (test) ->
    property = new properties.IntegerProperty()
    property.propertyName = 'property'
    _parseInt = global.parseInt
    global.parseInt = (value) ->
        test.equal value, 3
        value
    instance =
        property: 3
    result = property.toDb instance
    test.equal result, 3
    test.expect 2
    test.done()
    global.parseInt = _parseInt

exports.testFloatPropertyToJsWithNull = (test) ->
    property = new properties.FloatProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testFloatPropertyToJsWithNullAndDefaultValue = (test) ->
    property = new properties.FloatProperty
        default: 2.2
    result = property.toJs null
    test.equal result, 2.2
    test.expect 1
    test.done()

exports.testFloatPropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.FloatProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testFloatPropertyToJsWithoutNull = (test) ->
    _parseFloat = global.parseFloat
    property = new properties.FloatProperty()
    global.parseFloat = (value) ->
        test.equal value, 3.2
        value
    result = property.toJs 3.2
    test.equal result, 3.2
    test.expect 2
    test.done()
    global.parseFloat = _parseFloat

exports.testFloatPropertyToDbWithNull = (test) ->
    property = new properties.FloatProperty()
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, null
    test.expect 1
    test.done()

exports.testFloatPropertyToDbWithNullAndDefaultValue = (test) ->
    property = new properties.FloatProperty
        default: 2.2
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, 2.2
    test.equal instance.property, 2.2
    test.expect 2
    test.done()

exports.testFloatPropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.FloatProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testFloatPropertyToDbWithoutNull = (test) ->
    property = new properties.FloatProperty()
    property.propertyName = 'property'
    _parseFloat = global.parseFloat
    global.parseFloat = (value) ->
        test.equal value, 3.2
        value
    instance =
        property: 3.2
    result = property.toDb instance
    test.equal result, 3.2
    test.expect 2
    test.done()
    global.parseFloat = _parseFloat
