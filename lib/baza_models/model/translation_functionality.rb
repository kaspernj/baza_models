module BazaModels::Model::TranslationFunctionality
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def human_attribute_name(attribute_name)
      class_name = StringCases.camel_to_snake(name)

      keys = [
        "baza_models.attributes.#{class_name}.#{attribute_name}",
        "activerecord.attributes.#{class_name}.#{attribute_name}"
      ]

      keys.each do |key|
        return I18n.t(key) if I18n.exists?(key)
      end

      StringCases.snake_to_camel(attribute_name)
    end

    def model_name
      BazaModels::ClassTranslation.new(class: self)
    end
  end

  def model_name
    self.class.model_name
  end
end
