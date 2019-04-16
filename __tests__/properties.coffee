properties = require '../lib/properties'
exceptions = require '../lib/exceptions'


afterEach ->
    jest.restoreAllMocks()

test 'Initial property.', ->
    property = new properties.StringProperty
        required: yes
        dbField: 'field'
        type: 'string'
        index: 'index'
        analyzer: 'keyword'
        mapping:
            analyzer: 'keyword'
        default: 'default'
    expect(property).toMatchSnapshot()


# String Property
test 'The default string property is optional.', ->
    property = new properties.StringProperty()
    expect(property.required).toBe no

test 'The default value of string property is null.', ->
    property = new properties.StringProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the string property.', ->
    property = new properties.StringProperty
        default: 'default'
    property.propertyName = 'property'
    expect(property.toJs(null)).toBe 'default'
    instance =
        property: null
    expect(property.toDb(instance)).toBe 'default'
    expect(instance.property).toBe 'default'

test 'Throw an error when the required string property get null.', ->
    property = new properties.StringProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the string property to the string.', ->
    property = new properties.StringProperty()
    property.propertyName = 'property'
    fakeToString = jest.fn -> 'string'
    instance =
        property:
            toString: jest.fn -> 'string'
    expect(property.toJs(toString: fakeToString)).toBe 'string'
    expect(fakeToString).toBeCalled()
    expect(property.toDb(instance)).toBe 'string'
    expect(instance.property.toString).toBeCalled()


# Integer Property
test 'The default integer property is optional.', ->
    property = new properties.IntegerProperty()
    expect(property.required).toBe no

test 'The default value of integer property is null.', ->
    property = new properties.IntegerProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the integer property.', ->
    property = new properties.IntegerProperty
        default: 2
    property.propertyName = 'property'
    expect(property.toJs(null)).toBe 2
    instance =
        property: null
    expect(property.toDb(instance)).toBe 2
    expect(instance.property).toBe 2

test 'Throw an error when the required integer property get null.', ->
    property = new properties.IntegerProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the integer property to the integer.', ->
    property = new properties.IntegerProperty()
    jest.spyOn global, 'parseInt'
    property.propertyName = 'property'
    instance =
        property: 2
    expect(property.toJs(2)).toBe 2
    expect(property.toDb(instance)).toBe 2
    expect(global.parseInt).toBeCalledTimes 2


# Float property
test 'The default float property is optional.', ->
    property = new properties.FloatProperty()
    expect(property.required).toBe no

test 'The default value of float property is null.', ->
    property = new properties.FloatProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the float property.', ->
    property = new properties.FloatProperty
        default: 3.2
    property.propertyName = 'property'
    expect(property.toJs(null)).toBe 3.2
    instance =
        property: null
    expect(property.toDb(instance)).toBe 3.2
    expect(instance.property).toBe 3.2

test 'Throw an error when the required float property get null.', ->
    property = new properties.FloatProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the float property to the float.', ->
    property = new properties.FloatProperty()
    jest.spyOn global, 'parseFloat'
    property.propertyName = 'property'
    instance =
        property: 3.2
    expect(property.toJs(3.2)).toBe 3.2
    expect(property.toDb(instance)).toBe 3.2
    expect(global.parseFloat).toBeCalledTimes 2


# Boolean property
test 'The default boolean property is optional.', ->
    property = new properties.BooleanProperty()
    expect(property.required).toBe no

test 'The default value of boolean property is null.', ->
    property = new properties.BooleanProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the boolean property.', ->
    property = new properties.BooleanProperty
        default: yes
    property.propertyName = 'property'
    expect(property.toJs(null)).toBe yes
    instance =
        property: null
    expect(property.toDb(instance)).toBe yes
    expect(instance.property).toBe yes

test 'Throw an error when the required boolean property get null.', ->
    property = new properties.BooleanProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the boolean property to the boolean.', ->
    property = new properties.BooleanProperty()
    jest.spyOn global, 'Boolean'
    property.propertyName = 'property'
    instance =
        property: yes
    expect(property.toJs(yes)).toBe yes
    expect(property.toDb(instance)).toBe yes
    expect(global.Boolean).toBeCalledTimes 2


# Date property
test 'The default date property is optional.', ->
    property = new properties.DateProperty()
    expect(property.required).toBe no

test 'The default value of date property is null.', ->
    property = new properties.DateProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the date property.', ->
    defaultValue = new Date()
    property = new properties.DateProperty
        default: defaultValue
    property.propertyName = 'property'
    expect(property.toJs(null)).toEqual defaultValue
    instance =
        property: null
    expect(property.toDb(instance)).toBe defaultValue.toJSON()
    expect(instance.property).toEqual defaultValue

test 'Throw an error when the required date property get null.', ->
    property = new properties.DateProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the date property to the date.', ->
    date = new Date()
    property = new properties.DateProperty()
    property.propertyName = 'property'
    instance =
        property: date
    expect(property.toJs(date.toJSON())).toEqual date
    expect(property.toDb(instance)).toBe date.toJSON()


# List property
test 'Initial list property.', ->
    property = new properties.ListProperty
        itemClass: properties.StringProperty
    expect(property.itemClass).toBe properties.StringProperty

test 'The default value of list property is null.', ->
    property = new properties.ListProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the list property.', ->
    defaultValue = []
    property = new properties.ListProperty
        default: defaultValue
    property.propertyName = 'property'
    expect(property.toJs(null)).toEqual defaultValue
    instance =
        property: null
    expect(property.toDb(instance)).toEqual defaultValue
    expect(instance.property).toEqual defaultValue

test 'Throw an error when the required list property get null.', ->
    property = new properties.ListProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the string list property to the list.', ->
    property = new properties.ListProperty
        itemClass: properties.StringProperty
    property.propertyName = 'property'
    instance =
        property: ['itemA', 'itemB']
    expect(property.toJs(['itemA', 'itemB'])).toEqual ['itemA', 'itemB']
    expect(property.toDb(instance)).toEqual ['itemA', 'itemB']

test 'Convert the value of the integer list property to the list.', ->
    property = new properties.ListProperty
        itemClass: properties.IntegerProperty
    property.propertyName = 'property'
    instance =
        property: [2, 3]
    expect(property.toJs([2, 3])).toEqual [2, 3]
    expect(property.toDb(instance)).toEqual [2, 3]

test 'Convert the value of the float list property to the list.', ->
    property = new properties.ListProperty
        itemClass: properties.FloatProperty
    property.propertyName = 'property'
    instance =
        property: [3.1, 3.3]
    expect(property.toJs([3.1, 3.3])).toEqual [3.1, 3.3]
    expect(property.toDb(instance)).toEqual [3.1, 3.3]

test 'Convert the value of the boolean list property to the list.', ->
    property = new properties.ListProperty
        itemClass: properties.BooleanProperty
    property.propertyName = 'property'
    instance =
        property: [yes, no]
    expect(property.toJs([yes, no])).toEqual [yes, no]
    expect(property.toDb(instance)).toEqual [yes, no]

test 'Convert the value of the date list property to the list.', ->
    property = new properties.ListProperty
        itemClass: properties.DateProperty
    property.propertyName = 'property'
    instance =
        property: [new Date('2019-01-29T06:01:00.000Z')]
    expect(property.toJs(['2019-01-29T06:01:00.000Z'])).toEqual [new Date('2019-01-29T06:01:00.000Z')]
    expect(property.toDb(instance)).toEqual ['2019-01-29T06:01:00.000Z']

test 'Direct pass the value of object list properties to the list.', ->
    property = new properties.ListProperty
        itemClass: properties.ObjectProperty
    property.propertyName = 'property'
    instance =
        property: [{a: yes}]
    expect(property.toJs([{a: yes}])).toEqual [{a: yes}]
    expect(property.toDb(instance)).toEqual [{a: yes}]


# Object property
test 'The default value of object property is null.', ->
    property = new properties.ObjectProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the object property.', ->
    defaultValue =
        key: 'the-key'
    property = new properties.ObjectProperty
        default: defaultValue
    property.propertyName = 'property'
    expect(property.toJs(null)).toEqual defaultValue
    instance =
        property: null
    expect(property.toDb(instance)).toEqual defaultValue
    expect(instance.property).toEqual defaultValue

test 'Throw an error when the required object property get null.', ->
    property = new properties.ObjectProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the object property to the object.', ->
    property = new properties.ObjectProperty()
    property.propertyName = 'property'
    instance =
        property:
            key: 'the-key'
    expect(property.toJs(key: 'the-key')).toEqual key: 'the-key'
    expect(property.toDb(instance)).toEqual key: 'the-key'


# Reference property
test 'The default value of reference property is null.', ->
    property = new properties.ReferenceProperty()
    property.propertyName = 'property'
    expect(property.toJs(null)).toBeNull()
    expect(property.toDb(property: null)).toBeNull()

test 'The default value config of the reference property.', ->
    defaultValue = 'default'
    property = new properties.ReferenceProperty
        default: defaultValue
    property.propertyName = 'property'
    expect(property.toJs(null)).toBe defaultValue
    instance =
        property: null
    expect(property.toDb(instance)).toBe defaultValue
    expect(instance.property).toBe defaultValue

test 'Throw an error when the required reference property get null.', ->
    property = new properties.ReferenceProperty
        required: yes
    property.propertyName = 'property'
    expect(-> property.toJs null).toThrow exceptions.ValueRequiredError
    expect(-> property.toDb property: null).toThrow exceptions.ValueRequiredError

test 'Convert the value of the reference property to the string.', ->
    property = new properties.ReferenceProperty()
    property.propertyName = 'property'
    instance =
        property: 'key'
    expect(property.toJs('key')).toBe 'key'
    expect(property.toDb(instance)).toBe 'key'

test 'Set reference class of the reference property.', ->
    class Test
        constructor: (args) -> {@id} = args
    property = new properties.ReferenceProperty
        referenceClass: Test
    property.propertyName = 'property'
    expect(property.toJs(new Test(id: 'id'))).toMatchSnapshot()
    expect(property.toDb(property: new Test(id: 'id'))).toBe 'id'
