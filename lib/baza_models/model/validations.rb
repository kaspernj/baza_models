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
        next unless validator.fire?(self)

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

    @errors.empty?
  end

  module ClassMethods
    def validates(*attribute_names, args)
      special_args = {
        if: args.delete(:if)
      }

      attribute_names.each do |attribute_name|
        args.each do |validator_name, _validator_args|
          validator_camel_name = StringCases.snake_to_camel(validator_name)
          class_name = "#{validator_camel_name}Validator"

          __validators[attribute_name] ||= []
          __validators[attribute_name] << BazaModels::Validators.const_get(class_name).new(attribute_name, args.merge(special_args))
        end
      end
    end

    def validates_confirmation_of(*args)
      validate_shortcut(:confirmation, args)
    end

    def validates_format_of(*args)
      validate_shortcut(:format, args)
    end

    def validates_length_of(*args)
      validate_shortcut(:length, args)
    end

    def validates_presence_of(*args)
      validate_shortcut(:presence, args)
    end

    def validates_uniqueness_of(*args)
      validate_shortcut(:uniqueness, args)
    end

    def validate_shortcut(type, args)
      if args.last.is_a?(Hash)
        before_opts = args.pop

        opts = {type => before_opts}
        opts[:if] = before_opts.delete(:if) if before_opts.key?(:if)
      else
        opts = {type => true}
      end

      validates(*args, opts)
    end

    def __validators
      @validators ||= {}
    end
  end
end
