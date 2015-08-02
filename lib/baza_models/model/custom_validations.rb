module BazaModels::Model::CustomValidations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :custom_validations

    def validate(method_name)
      @custom_validations ||= []
      @custom_validations << method_name
    end
  end

private

  def execute_custom_validations
    return unless self.class.custom_validations

    self.class.custom_validations.each do |method_name|
      __send__(method_name)
    end
  end
end
