class BazaModels::Validators::FormatValidator < BazaModels::Validators::BaseValidator
  def validate(model, value)
    model.errors.add(attribute_name, "has an invalid format") unless value.to_s.match(format_regex)
  end

private

  def format_regex
    @args.fetch(:format)[:with]
  end
end
