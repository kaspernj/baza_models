module BazaModels::Model::Validations
  def self.included(base)
    base.extend(ClassMethods)
  end

  def valid?
    fire_callbacks(:before_validation)

    if new_record?
      fire_callbacks(:before_validation_on_create)
    else
      fire_callbacks(:before_validation_on_update)
    end

    reset_errors

    validators = self.class.__validators

    merged_data = @data.merge(@changes)
    merged_data.each do |attribute_name, attribute_value|
      next unless validators.key?(attribute_name)

      validators[attribute_name].each do |validator|
        validator.validate(self, attribute_value)
      end
    end

    execute_custom_validations
    fire_callbacks(:after_validation)

    if new_record?
      fire_callbacks(:after_validation_on_create)
    else
      fire_callbacks(:after_validation_on_update)
    end

    return @errors.empty?
  end

  module ClassMethods
    def validates(*attribute_names, args)
      attribute_names.each do |attribute_name|
        args.each do |validator_name, validator_args|
          validator_camel_name = StringCases.snake_to_camel(validator_name)
          class_name = "#{validator_camel_name}Validator"

          __validators[attribute_name] ||= []
          __validators[attribute_name] << BazaModels::Validators.const_get(class_name).new(attribute_name, args)
        end
      end
    end

    def validates_presence_of(*attributes)
      validates *attributes, presence: true
    end

    def __validators
      @validators ||= {}
    end
  end
end
