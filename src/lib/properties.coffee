exceptions = require './exceptions'


class Property
    ###
    @property default {bool}
    @property required {bool}
    @property dbField {string}
    @property type {string}  For elasticsearch mapping
    @property index {string}  For elasticsearch mapping
    @property analyzer {string}  For elasticsearch mapping
    @property mapping {object}  For elasticsearch mapping
    @property propertyName {string} The property name in the document. It will be set at Document.define()
    ###
    constructor: (args={}) ->
        {
        @default,
        @required,
        @dbField,
        @type,
        @index,
        @analyzer,
        @mapping,
        } = args
        @required ?= no

class StringProperty extends Property
    constructor: (args) ->
        super args
    toJs: (value) ->
        ###
        Convert value for initial Document.
        @param classInstance: {Document} The instance of the document.
        @returns {string}
        ###
        if not value?
            if @default?
                return @default.toString()
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        value.toString()
    toDb: (classInstance) ->
        ###
        Convert value for writing database.
        @param classInstance: {Document} The instance of the document.
        @returns {string}
        ###
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
    toJs: (value) ->
        if not value?
            if @default?
                return parseInt @default
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        parseInt value
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
    toJs: (value) ->
        if not value?
            if @default?
                return parseFloat @default
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        parseFloat value
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
    toJs: (value) ->
        if not value?
            if @default?
                return Boolean @default
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        Boolean value
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
    toJs: (value) ->
        if not value?
            if @autoNow
                return new Date()
            else if @default?
                return new Date(@default)
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        new Date(value)
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
    toJs: (value) ->
        if not value?
            if @default?
                return @default
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        if @itemClass?
            switch @itemClass
                when StringProperty
                    value = ((if x? then x.toString() else null) for x in value)
                when IntegerProperty
                    value = ((if x? then parseInt(x) else null) for x in value)
                when FloatProperty
                    value = ((if x? then parseFloat(x) else null) for x in value)
                when BooleanProperty
                    value = ((if x? then Boolean(x) else null) for x in value)
                when DateProperty
                    value = ((if x? then x.toJSON() else null) for x in value)
                when ListProperty, ObjectProperty, ReferenceProperty
                    value = ((if x? then x else null) for x in value)
                else
                    value = ((if x? then new itemClass(x) else null) for x in value)
        value
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
            switch @itemClass
                when StringProperty
                    value = ((if x? then x.toString() else null) for x in value)
                when IntegerProperty
                    value = ((if x? then parseInt(x) else null) for x in value)
                when FloatProperty
                    value = ((if x? then parseFloat(x) else null) for x in value)
                when BooleanProperty
                    value = ((if x? then Boolean(x) else null) for x in value)
                when DateProperty
                    value = ((if x? then x.toJSON() else null) for x in value)
                when ListProperty, ObjectProperty, ReferenceProperty
                    value = ((if x? then x else null) for x in value)
                else
                    value = ((if x? then new itemClass(x) else null) for x in value)
        value
exports.ListProperty = ListProperty

class ObjectProperty extends Property
    constructor: (args) ->
        super args
    toJs: (value) ->
        if not value?
            if @default?
                return @default
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        value
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
    toJs: (value) ->
        if not value?
            if @default?
                return @default
            if @required
                throw new exceptions.ValueRequiredError("#{@propertyName} is required.")
            return null
        if typeof(value) is 'string'
            value
        else if typeof(value) is 'object' and value.constructor is @referenceClass
            value
        else
            throw new exceptions.TypeError("#{@propertyName} has wrong type.")
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
