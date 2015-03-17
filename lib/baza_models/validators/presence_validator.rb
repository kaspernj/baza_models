class BazaModels::Validators::PresenceValidator < BazaModels::Validators::BaseValidator
  def validate(model, value)
    model.errors.add(attribute_name, "cannot be blank") if value.to_s.strip.empty?
  end
end
