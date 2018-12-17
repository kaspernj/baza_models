class BazaModels::Ransacker::RelationshipScanner
  def initialize(args)
    @join_parts = args[:join_parts] || []
    @mode = args.fetch(:mode)
    @ransacker = args.fetch(:ransacker)
    @db = @ransacker.db
    @value = args.fetch(:value)

    if args[:column_name]
      @name_parts = args.fetch(:column_name).split("_")
    else
      @name_parts = args.fetch(:name_parts)
    end

    if args[:klass]
      @klass = args.fetch(:klass)
    else
      @klass = @ransacker.klass
    end

    parse_relation
  end

private

  def parse_relation
    current_name = []
    relationships = @klass.relationships

    loop do
      break if @name_parts.empty?
      name_part = @name_parts.shift
      current_name << name_part

      relationships.each do |relationship_name, relationship|
        next unless relationship_name.to_s == current_name.join("_")

        @join_parts << relationship_name

        BazaModels::Ransacker::RelationshipScanner.new(
          join_parts: @join_parts,
          klass: StringCases.constantize(relationship.fetch(:class_name)),
          name_parts: @name_parts,
          mode: @mode,
          ransacker: @ransacker,
          value: @value
        )
        return nil
      end

      name = current_name.join("_")
      @klass.column_names.each do |column_name|
        next unless name == column_name

        add_filter_to_query(
          column_name: column_name
        )
        return nil
      end
    end

    raise "Could not figure out relationships based on name: #{current_name.join("_")}"
  end

  def join_parts_as_hash
    return @join_parts.first if @join_parts.length == 1

    hash = {}
    current_hash = hash
    join_parts = @join_parts.clone

    loop do
      break if join_parts.empty?
      join_part = join_parts.shift

      if join_parts.length == 1
        current_hash[join_part] = join_parts.shift
        break
      else
        current_hash[join_part] = {}
        current_hash = current_hash.fetch(join_part)
      end
    end

    hash
  end

  def add_join_parts
    @ransacker.query = @ransacker.query.joins(join_parts_as_hash) if @join_parts.any?
  end

  def add_filter_to_query(args)
    @column_query = "#{@db.sep_col}#{@db.escape_column(args.fetch(:column_name))}#{@db.sep_col}"
    @table_query = "#{@db.sep_table}#{@db.escape_table(@klass.table_name)}#{@db.sep_table}"

    case @mode
    when :cont
      return if @value.empty?
      add_query_with_symbol("LIKE", "%#{@klass.db.esc(@value)}%")
    when :eq
      add_query_with_symbol("=")
    when :lt
      add_query_with_symbol("<")
    when :lteq
      add_query_with_symbol("<=")
    when :gt
      add_query_with_symbol(">")
    when :gteq
      add_query_with_symbol(">=")
    when :sort
      add_join_parts
      @ransacker.query = @ransacker
        .query
        .order("#{@table_query}.#{@column_query} #{@value}")
    else
      raise "Unknown mode: #{@mode}"
    end
  end

  def add_query_with_symbol(symbol, value = @value)
    add_join_parts
    @ransacker.query = @ransacker
      .query
      .where("#{@table_query}.#{@column_query} #{symbol} #{@klass.db.quote_value(value)}")
  end
end
