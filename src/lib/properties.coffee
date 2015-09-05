exceptions = require './exceptions'


class Property
    ###
    @property default: {bool}
    @property required: {bool}
    @property dbField: {string}
    @property analyzer: {string}
    @property mapping: {object}
    @property propertyName: {string} The property name. It will be set at Document.define()
    ###
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
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = @default.toString()
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        value.toString()

exports.IntegerProperty = class NumberProperty extends Property
    constructor: (args) ->
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = parseInt @default
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        parseInt value

exports.FloatProperty = class FloatProperty extends Property
    constructor: (args) ->
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = parseFloat @default
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        parseFloat value

exports.BooleanProperty = class BooleanProperty extends Property
    constructor: (args) ->
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = Boolean @default
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        Boolean value

exports.DateProperty = class DateProperty extends Property
    constructor: (args={}) ->
        {@autoNow} = args
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @autoNow
                classInstance[@propertyName] = new Date()
                return classInstance[@propertyName].toJSON()
            else if @default?
                classInstance[@propertyName] = new Date(@default)
                return classInstance[@propertyName].toJSON()
            else
                if @required
                    throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        value.toJSON()


# not imprement --------------------------------------------------

exports.ListProperty = class DateProperty extends Property
    constructor: (args={}) ->
        {@itemClass} = args
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null

exports.ObjectProperty = class ObjectProperty extends Property
    constructor: (args) ->
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null

exports.ReferenceProperty = class ReferenceProperty extends Property
    constructor: (args={}) ->
        {@referenceClass} = args
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
