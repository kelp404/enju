(function() {
  var BooleanProperty, DateProperty, FloatProperty, NumberProperty, ObjectProperty, Property, ReferenceProperty, StringProperty,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  exports.Property = Property = (function() {
    function Property(args) {
      if (args == null) {
        args = {};
      }
      this["default"] = args["default"], this.required = args.required, this.dbField = args.dbField, this.analyzer = args.analyzer, this.mapping = args.mapping;
      if (this.required == null) {
        this.required = false;
      }
    }

    return Property;

  })();

  exports.StringProperty = StringProperty = (function(superClass) {
    extend(StringProperty, superClass);

    function StringProperty(args) {
      StringProperty.__super__.constructor.call(this, args);
    }

    return StringProperty;

  })(Property);

  exports.IntegerProperty = NumberProperty = (function(superClass) {
    extend(NumberProperty, superClass);

    function NumberProperty(args) {
      NumberProperty.__super__.constructor.call(this, args);
    }

    return NumberProperty;

  })(Property);

  exports.FloatProperty = FloatProperty = (function(superClass) {
    extend(FloatProperty, superClass);

    function FloatProperty(args) {
      FloatProperty.__super__.constructor.call(this, args);
    }

    return FloatProperty;

  })(Property);

  exports.BooleanProperty = BooleanProperty = (function(superClass) {
    extend(BooleanProperty, superClass);

    function BooleanProperty(args) {
      BooleanProperty.__super__.constructor.call(this, args);
    }

    return BooleanProperty;

  })(Property);

  exports.DateProperty = DateProperty = (function(superClass) {
    extend(DateProperty, superClass);

    function DateProperty(args) {
      if (args == null) {
        args = {};
      }
      this.autoNow = args.autoNow;
      DateProperty.__super__.constructor.call(this, args);
    }

    return DateProperty;

  })(Property);

  exports.ListProperty = DateProperty = (function(superClass) {
    extend(DateProperty, superClass);

    function DateProperty(args) {
      if (args == null) {
        args = {};
      }
      this.itemClass = args.itemClass;
      DateProperty.__super__.constructor.call(this, args);
    }

    return DateProperty;

  })(Property);

  exports.ObjectProperty = ObjectProperty = (function(superClass) {
    extend(ObjectProperty, superClass);

    function ObjectProperty(args) {
      ObjectProperty.__super__.constructor.call(this, args);
    }

    return ObjectProperty;

  })(Property);

  exports.ReferenceProperty = ReferenceProperty = (function(superClass) {
    extend(ReferenceProperty, superClass);

    function ReferenceProperty(args) {
      if (args == null) {
        args = {};
      }
      this.referenceClass = args.referenceClass;
      ReferenceProperty.__super__.constructor.call(this, args);
    }

    return ReferenceProperty;

  })(Property);

}).call(this);
