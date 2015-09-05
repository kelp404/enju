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

class StringProperty extends Property
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
exports.StringProperty = StringProperty

class IntegerProperty extends Property
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
exports.IntegerProperty = IntegerProperty

class FloatProperty extends Property
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
exports.FloatProperty = FloatProperty

class BooleanProperty extends Property
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
exports.BooleanProperty = BooleanProperty

class DateProperty extends Property
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
exports.DateProperty = DateProperty

class ListProperty extends Property
    constructor: (args={}) ->
        {@itemClass} = args
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = @default
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        if @itemClass?
            switch itemClass
                when StringProperty
                    value = [if x? then x.toString() else null for x in value]
                when IntegerProperty
                    value = [if x? then parseInt(x) else null for x in value]
                when FloatProperty
                    value = [if x? then parseFloat(x) else null for x in value]
                when BooleanProperty
                    value = [if x? then Boolean(x) else null for x in value]
                when DateProperty
                    value = [if x? then x.toJSON() else null for x in value]
                when ListProperty, ObjectProperty, ReferenceProperty
                    value = [if x? then x else null for x in value]
                else
                    value = [if x? then new itemClass(x) else null for x in value]
            value
        else
            value
exports.ListProperty = ListProperty

class ObjectProperty extends Property
    constructor: (args) ->
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = @default
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        value
exports.ObjectProperty = ObjectProperty

class ReferenceProperty extends Property
    constructor: (args={}) ->
        {@referenceClass} = args
        super args
    toDb: (classInstance) ->
        value = classInstance[@propertyName]
        if not value?
            if @default?
                classInstance[@propertyName] = @default
                return classInstance[@propertyName]
            if @required
                throw new exceptions.ValueRequiredError("#{classInstance.constructor.name}.#{@propertyName} is required.")
            return null
        if typeof(value) is 'string'
            value
        else if typeof(value) is 'object' and value.constructor is @referenceClass
            value.id
        else
            throw new exceptions.TypeError("#{classInstance.constructor.name}.#{@propertyName} has wrong type.")
exports.ReferenceProperty = ReferenceProperty
