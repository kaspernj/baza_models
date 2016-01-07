class BazaModels::Query::Inspector
  def initialize(args)
    @query = args.fetch(:query)
    @model = args.fetch(:model)
    @argument = args.fetch(:argument)
    @joins = args.fetch(:joins)
    @joins_tracker = args.fetch(:joins_tracker)
  end

  def execute
    inspect_argument(@argument)
  end

private

  def inspect_argument(argument)
    if argument.is_a?(Hash)
      inspect_hash(argument)
    elsif argument.is_a?(Array)
      argument.each do |argument_i|
        inspect_argument(argument_i)
      end
    elsif argument.is_a?(Symbol)
      inspect_symbol(argument)
    elsif argument.is_a?(String)
      inspect_string(argument)
    end
  end

  def inspect_string(argument)
    @joins << argument
  end

  def inspect_symbol(argument)
    return if @joins_tracker.include?(argument)

    relationship_pair = @model.relationships.detect { |key, _value| key == argument }
    raise "Could not find a relationship on #{@model.name} by that name: #{argument}" unless relationship_pair
    relationship = relationship_pair[1]

    table_name = relationship.fetch(:table_name)

    if relationship.fetch(:type) == :belongs_to
      column_left = :id
      column_right = relationship.fetch(:foreign_key)
    else
      column_left = relationship.fetch(:foreign_key)
      column_right = :id
    end

    orig_table = @model.table_name

    @joins << "INNER JOIN `#{table_name}` ON `#{table_name}`.`#{column_left}` = `#{orig_table}`.`#{column_right}`"
    @joins_tracker[argument] = {}
  end

  def inspect_hash(argument)
    argument.each do |key, value|
      inspect_symbol(key)

      relationship_pair = @model.relationships.detect { |relationship_name, _relationship| relationship_name == key }
      raise "Could not find a relationship on #{@model.name} by that name: #{value}" unless relationship_pair
      relationship = relationship_pair[1]

      BazaModels::Query::Inspector.new(
        query: @query,
        argument: value,
        model: StringCases.constantize(relationship.fetch(:class_name)),
        joins: @joins,
        joins_tracker: @joins_tracker[key]
      ).execute
    end
  end
end
