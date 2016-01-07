class BazaModels::ClassTranslation
  def initialize(args)
    @klass = args.fetch(:class)
  end

  def class_name_snake
    @class_name_snake ||= StringCases.camel_to_snake(@klass.name.split("::").last)
  end

  def class_name_snake_with_parents
    unless @class_name_snake_with_parents
      name = @klass.name
        .split("::")
        .map { |name_part| StringCases.camel_to_snake(name_part) }
        .join("\\")

      @class_name_snake_with_parents = name
    end

    @class_name_snake_with_parents
  end

  def human(args = {})
    if args[:count] && args[:count] >= 2
      count_key = "other"
    else
      count_key = "one"
    end

    keys = [
      "baza_models.models.#{class_name_snake_with_parents}.#{count_key}",
      "activerecord.models.#{class_name_snake_with_parents}.#{count_key}"
    ]

    keys.each do |key|
      return I18n.t(key) if I18n.exists?(key)
    end

    @klass.name.split("::").last
  end

  def param_key
    @param_key ||= class_name_snake
  end

  def route_key
    "#{param_key}s"
  end

  def singular_route_key
    param_key
  end

  def i18n_key
    param_key.to_sym
  end
end
