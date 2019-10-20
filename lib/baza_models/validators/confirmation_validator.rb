class BazaModels::Validators::ConfirmationValidator < BazaModels::Validators::BaseValidator
  def validate(model, value)
    confirmation_attribute_name = "#{attribute_name}_confirmation"
    confirmation_value = model.__send__(confirmation_attribute_name)

    model.errors.add(attribute_name, "hasn't been confirmed") if value && !confirmation_value

    model.errors.add(attribute_name, "was not the same as the confirmation") if value && confirmation_value && confirmation_value != value
  end
end
