class BazaModels::Errors
  class InvalidRecord < RuntimeError; end
  class RecordNotFound < RuntimeError; end

  def initialize
    @errors = {}
  end

  def add(attribute_name, error)
    @errors[attribute_name] ||= []
    @errors[attribute_name] << error
  end

  def full_messages
    messages = []

    @errors.each do |attribute_name, errors|
      errors.each do |error|
        message = ""

        message << "#{StringCases.snake_to_camel(attribute_name)} " unless attribute_name == :base

        message << error
        messages << message
      end
    end

    messages
  end

  def empty?
    full_messages.empty?
  end

  def any?
    full_messages.any?
  end

  def to_s
    "#<BazaModels::Errors full_messages=\"#{full_messages}\">"
  end

  def inspect
    to_s
  end

  def [](key)
    @errors[key] || []
  end
end
