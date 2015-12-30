class BazaModels::Validators::LengthValidator < BazaModels::Validators::BaseValidator
  def validate(model, value)
    model.errors.add(attribute_name, "is too long") if max_length && value.to_s.length > max_length
    model.errors.add(attribute_name, "is too short") if min_length && value.to_s.length < min_length
  end

private

  def max_length
    @args.fetch(:length)[:maximum]
  end

  def min_length
    @args.fetch(:length)[:minimum]
  end
end
