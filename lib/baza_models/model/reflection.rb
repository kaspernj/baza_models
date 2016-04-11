class BazaModels::Model::Reflection
  def initialize(relationship)
    @relationship = relationship
  end

  def class_name
    @relationship.fetch(:class_name)
  end

  def collection?
    @relationship.fetch(:type) == :has_many
  end

  def foreign_key
    @relationship.fetch(:foreign_key).to_s
  end

  def klass
    StringCases.constantize(class_name)
  end

  def name
    @relationship.fetch(:relation_name)
  end
end
