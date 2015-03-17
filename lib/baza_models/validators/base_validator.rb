class BazaModels::Validators::BaseValidator
  attr_reader :attribute_name, :args

  def initialize(attribute_name, args)
    @attribute_name = attribute_name
    @args = args
  end
end
