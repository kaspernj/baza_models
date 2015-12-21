class BazaModels::ClassTranslation
  def initialize(args)
    @klass = args.fetch(:class)
  end

  def class_name_snake
    @class_name_snake ||= StringCases.camel_to_snake(@klass.name)
  end

  def human(args = {})
    if args[:count] && args[:count] >= 2
      count_key = "other"
    else
      count_key = "one"
    end

    keys = ["baza_models.models.#{class_name_snake}.#{count_key}", "activerecord.models.#{class_name_snake}.#{count_key}"]

    keys.each do |key|
      return I18n.t(key) if I18n.exists?(key)
    end

    @klass.name
  end

  def param_key
    @param_key ||= class_name_snake
  end

  def route_key
    "#{param_key}s"
  end
end
