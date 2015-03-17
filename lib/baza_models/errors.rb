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
      messages += errors
    end

    return messages
  end

  def empty?
    full_messages.empty?
  end

  def any?
    full_messages.any?
  end
end
