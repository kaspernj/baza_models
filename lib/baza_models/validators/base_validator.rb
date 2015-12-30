class BazaModels::Validators::BaseValidator
  attr_reader :attribute_name, :args

  def initialize(attribute_name, args)
    @attribute_name = attribute_name
    @args = args
  end

  def fire?(model)
    result = true

    if @args[:if]
      if @args.fetch(:if).is_a?(Symbol)
        result = model.__send__(@args.fetch(:if))
      else
        raise "Unknown 'if'-argument: #{@args[:if]} (#{@args[:if].class.name})"
      end
    end

    result
  end
end
