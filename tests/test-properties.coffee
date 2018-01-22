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

exports.testBooleanPropertyToJsWithNull = (test) ->
    property = new properties.BooleanProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testBooleanPropertyToJsWithNullAndDefaultValue = (test) ->
    property = new properties.BooleanProperty
        default: yes
    result = property.toJs null
    test.equal result, yes
    test.expect 1
    test.done()

exports.testBooleanPropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.BooleanProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testBooleanPropertyToJsWithoutNull = (test) ->
    property = new properties.BooleanProperty()
    _boolean = global.Boolean
    global.Boolean = (value) ->
        test.equal value, yes
        value
    result = property.toJs yes
    test.equal result, yes
    test.expect 2
    test.done()
    global.Boolean = _boolean

exports.testBooleanPropertyToDbWithNull = (test) ->
    property = new properties.BooleanProperty()
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, null
    test.expect 1
    test.done()

exports.testBooleanPropertyToDbWithNullAndDefaultValue = (test) ->
    property = new properties.BooleanProperty
        default: yes
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, yes
    test.equal instance.property, yes
    test.expect 2
    test.done()

exports.testBooleanPropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.BooleanProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testBooleanPropertyToDbWithoutNull = (test) ->
    property = new properties.BooleanProperty()
    property.propertyName = 'property'
    _boolean = global.Boolean
    global.Boolean = (value) ->
        test.equal value, yes
        value
    instance =
        property: yes
    result = property.toDb instance
    test.equal result, yes
    test.expect 2
    test.done()
    global.Boolean = _boolean

exports.testDatePropertyToJsWithNull = (test) ->
    property = new properties.DateProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testDatePropertyToJsWithNullAndAutoNow = (test) ->
    property = new properties.DateProperty
        autoNow: yes
    _date = global.Date
    global.Date = class FakeDate
        constructor: ->
    result = property.toJs null
    global.Date = _date
    test.equal result.constructor, FakeDate
    test.expect 1
    test.done()

exports.testDatePropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.DateProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testDatePropertyToJsWithoutNull = (test) ->
    property = new properties.DateProperty()
    dateValue = new Date('2018-01-01T00:00:00')
    _date = global.Date
    global.Date = class FakeDate
        constructor: (value) ->
            test.equal value, dateValue
    result = property.toJs dateValue
    global.Date = _date
    test.equal result.constructor, FakeDate
    test.expect 2
    test.done()

exports.testDatePropertyToDbWithNull = (test) ->
    property = new properties.DateProperty()
    property.propertyName = 'property'
    instance =
        property: null
    result = property.toDb instance
    test.equal result, null
    test.expect 1
    test.done()

exports.testDatePropertyToDbWithNullAndAutoNow = (test) ->
    property = new properties.DateProperty
        autoNow: yes
    property.propertyName = 'property'
    instance =
        property: null
    _date = global.Date
    global.Date = class FakeDate
        constructor: ->
        toJSON: -> 'json'
    result = property.toDb instance
    global.Date = _date
    test.equal result, 'json'
    test.equal instance.property.constructor, FakeDate
    test.expect 2
    test.done()

exports.testDatePropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.DateProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testDatePropertyToDbWithoutNull = (test) ->
    property = new properties.DateProperty()
    property.propertyName = 'property'
    instance =
        property: new Date('2018-01-01T00:00:00.000Z')
    result = property.toDb instance
    test.equal result, '2018-01-01T00:00:00.000Z'
    test.expect 1
    test.done()

exports.testListProperty = (test) ->
    property = new properties.ListProperty
        itemClass: properties.StringProperty
    test.equal property.itemClass, properties.StringProperty
    test.expect 1
    test.done()

exports.testListPropertyToJsWithNull = (test) ->
    property = new properties.ListProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testListPropertyToJsWithNullAndDefaultValue = (test) ->
    defaultValue = []
    property = new properties.ListProperty
        default: defaultValue
    result = property.toJs null
    test.notEqual result, defaultValue
    test.equal result.constructor, Array
    test.equal result.length, 0
    test.expect 3
    test.done()

exports.testListPropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.ListProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testListPropertyToJsWithoutNull = (test) ->
    property = new properties.ListProperty()
    result = property.toJs 'string'
    test.equal result, 'string'
    test.expect 1
    test.done()

exports.testListPropertyToDbWithNull = (test) ->
    property = new properties.ListProperty()
    property.propertyName = 'property'
    result = property.toDb
        property: null
    test.equal result, null
    test.expect 1
    test.done()

exports.testListPropertyToDbWithNullAndDefaultValue = (test) ->
    defaultValue = []
    property = new properties.ListProperty
        default: defaultValue
    property.propertyName = 'property'
    result = property.toDb
        property: null
    test.notEqual result, defaultValue
    test.equal result.constructor, Array
    test.equal result.length, 0
    test.expect 3
    test.done()

exports.testListPropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.ListProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testListPropertyToDbWithoutNull = (test) ->
    property = new properties.ListProperty
        itemClass: properties.StringProperty
    property.propertyName = 'property'
    result = property.toDb
        property: ['item']
    test.deepEqual result, ['item']
    test.expect 1
    test.done()

exports.testObjectPropertyToJsWithNull = (test) ->
    property = new properties.ObjectProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testObjectPropertyToJsWithNullAndDefaultValue = (test) ->
    defaultValue =
        default: yes
    property = new properties.ObjectProperty
        default: defaultValue
    result = property.toJs null
    test.notEqual result, defaultValue
    test.deepEqual result, default: yes
    test.expect 2
    test.done()

exports.testObjectPropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.ObjectProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testObjectPropertyToJsWithoutNull = (test) ->
    property = new properties.ObjectProperty()
    result = property.toJs field: yes
    test.deepEqual result, field: yes
    test.expect 1
    test.done()

exports.testObjectPropertyToDbWithNull = (test) ->
    property = new properties.ObjectProperty()
    property.propertyName = 'property'
    result = property.toDb
        property: null
    test.equal result, null
    test.expect 1
    test.done()

exports.testObjectPropertyToDbWithNullAndDefaultValue = (test) ->
    defaultValue = default: yes
    property = new properties.ObjectProperty
        default: defaultValue
    property.propertyName = 'property'
    result = property.toDb
        property: null
    test.notEqual result, defaultValue
    test.deepEqual result, defaultValue
    test.expect 2
    test.done()

exports.testObjectPropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.ObjectProperty
        required: yes
    property.propertyName = 'property'
    instance =
        property: null
    test.throws -> property.toDb instance, Error
    test.expect 1
    test.done()

exports.testObjectPropertyToDbWithoutNull = (test) ->
    property = new properties.ObjectProperty()
    property.propertyName = 'property'
    result = property.toDb
        property:
            field: yes
    test.deepEqual result, field: yes
    test.expect 1
    test.done()

exports.testReferenceProperty = (test) ->
    property = new properties.ReferenceProperty
        referenceClass: 'reference'
    test.equal property.referenceClass, 'reference'
    test.expect 1
    test.done()

exports.testReferencePropertyToJsWithNull = (test) ->
    property = new properties.ReferenceProperty()
    result = property.toJs null
    test.equal result, null
    test.expect 1
    test.done()

exports.testReferencePropertyToJsWithNullAndDefaultValue = (test) ->
    property = new properties.ReferenceProperty
        default: 'default'
    result = property.toJs null
    test.equal result, 'default'
    test.expect 1
    test.done()

exports.testReferencePropertyToJsWithNullAndRequiredException = (test) ->
    property = new properties.ReferenceProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toJs null, Error
    test.expect 1
    test.done()

exports.testReferencePropertyToJsWithString = (test) ->
    property = new properties.ReferenceProperty()
    result = property.toJs 'string'
    test.equal result, 'string'
    test.expect 1
    test.done()

exports.testReferencePropertyToJsWithClass = (test) ->
    class Test
        constructor: (args) -> {@id} = args
    property = new properties.ReferenceProperty
        referenceClass: Test
    result = property.toJs new Test(id: 'id')
    test.equal result.constructor, Test
    test.equal result.id, 'id'
    test.expect 2
    test.done()

exports.testReferencePropertyToDbWithNull = (test) ->
    property = new properties.ReferenceProperty()
    property.propertyName = 'property'
    result = property.toDb
        property: null
    test.equal result, null
    test.expect 1
    test.done()

exports.testReferencePropertyToDbWithNullAndDefaultValue = (test) ->
    property = new properties.ReferenceProperty
        default: 'default'
    property.propertyName = 'property'
    result = property.toDb
        property: null
    test.equal result, 'default'
    test.expect 1
    test.done()

exports.testReferencePropertyToDbWithNullAndRequiredException = (test) ->
    property = new properties.ReferenceProperty
        required: yes
    property.propertyName = 'property'
    test.throws -> property.toDb null, Error
    test.expect 1
    test.done()

exports.testReferencePropertyToDbWithString = (test) ->
    property = new properties.ReferenceProperty()
    property.propertyName = 'property'
    result = property.toDb
        property: 'string'
    test.equal result, 'string'
    test.expect 1
    test.done()

exports.testReferencePropertyToDbWithClass = (test) ->
    class Test
        constructor: (args) -> {@id} = args
    property = new properties.ReferenceProperty
        referenceClass: Test
    property.propertyName = 'property'
    result = property.toDb
        property: new Test(id: 'id')
    test.equal result, 'id'
    test.expect 1
    test.done()
