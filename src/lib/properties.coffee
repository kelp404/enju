exports.Property = class Property
    constructor: (args={}) ->
        {
        @default,
        @required,
        @dbField,
        @analyzer,
        @mapping,
        } = args
        @required ?= no

exports.StringProperty = class StringProperty extends Property
    constructor: (args) ->
        super args

exports.IntegerProperty = class NumberProperty extends Property
    constructor: (args) ->
        super args

exports.FloatProperty = class FloatProperty extends Property
    constructor: (args) ->
        super args

exports.BooleanProperty = class BooleanProperty extends Property
    constructor: (args) ->
        super args

exports.DateProperty = class DateProperty extends Property
    constructor: (args={}) ->
        {@autoNow} = args
        super args

exports.ListProperty = class DateProperty extends Property
    constructor: (args={}) ->
        {@itemClass} = args
        super args

exports.ObjectProperty = class ObjectProperty extends Property
    constructor: (args) ->
        super args

exports.ReferenceProperty = class ReferenceProperty extends Property
    constructor: (args={}) ->
        {@referenceClass} = args
        super args
