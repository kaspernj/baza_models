class BazaModels::Validators::UniquenessValidator < BazaModels::Validators::BaseValidator
  def validate(model, value)
    query_same = model.class.where(attribute_name => value)

    scope&.each do |scope_part|
      query_same = query_same.where(scope_part => model.__send__(scope_part))
    end

    model.errors.add(attribute_name, "isn't unique") if query_same.any?
  end

private

  def scope
    scope = @args.fetch(:uniqueness)[:scope]
    scope = [scope] if scope && !scope.is_a?(Array)
    scope
  end
end
