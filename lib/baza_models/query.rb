require "array_enumerator"

class BazaModels::Query
  attr_accessor :_previous_model, :_relation

  def initialize(args)
    @args = args
    @model = @args[:model]
    @db = @model.db

    @wheres = []
    @includes = []
    @joins = []
    @groups = []
    @orders = []
  end

  def all
    return self
  end

  def includes(name)
    @includes << name
    return self
  end

  def where(args)
    if args.is_a?(String)
      @wheres << args
    else
      args.each do |key, value|
        if value.is_a?(Hash)
          value.each do |hash_key, hash_value|
            @wheres << "`#{key}`.`#{hash_key}` = '#{@db.esc(hash_value)}'"
          end
        else
          @wheres << "`#{@model.table_name}`.`#{key}` = '#{@db.esc(value)}'"
        end
      end
    end

    return self
  end

  def joins(name)
    if name.is_a?(String)
      @joins << name
    else
      relationship = @model.relationships.fetch(name)
      raise "No relationship by that name: #{name}" unless relationship

      table_name = relationship.fetch(:table_name)
      foreign_key = relationship.fetch(:foreign_key)

      orig_table = @model.table_name

      @joins << "INNER JOIN `#{table_name}` ON `#{table_name}`.`#{foreign_key}` = `#{orig_table}`.`id`"
    end

    return self
  end

  def to_enum
    if !any_mods? && autoloaded_on_previous_model?
      return @_previous_model.autoloads.fetch(@_relation.fetch(:relation_name))
    end

    array_enum = ArrayEnumerator.new do |yielder|
      @model.db.query(to_sql).each do |data|
        yielder << @model.new(data)
      end
    end

    if @includes.empty?
      return array_enum
    else
      array = array_enum.to_a

      if @includes.any? && array.any?
        autoloader = BazaModels::Autoloader.new(
          models: array,
          autoloads: @includes,
          db: @db
        )
        autoloader.autoload
      end

      return array
    end
  end

  def each
    to_enum.each do |model|
      yield model
    end
  end

  def to_a
    to_enum.to_a
  end

  def to_sql
    sql = "SELECT `#{@model.table_name}`.* FROM `#{@model.table_name}` "

    unless @joins.empty?
      @joins.each do |join|
        sql << join
        sql << " "
      end
    end

    unless @wheres.empty?
      sql << "WHERE "

      first = true
      @wheres.each do |where|
        if first == true
          first = false
        else
          sql << "AND "
        end

        sql << where
        sql << " "
      end
    end

    unless @orders.empty?
      sql << "ORDER BY "

      first = true
      @orders.each do |order|
        if first
          first = false
        else
          sql << ", "
        end

        sql << order.to_sql
      end
    end

    unless @groups.empty?
      sql << "GROUP BY "

      first = true
      @groups.each do |group|
        if first
          first = false
        else
          sql << ", "
        end
      end
    end

    return sql.strip
  end

  def to_s
    "#<BazaModels::Query class=#{@model.name} wheres=#{@wheres}>"
  end

  def inspect
    to_s
  end

private

  def any_mods?
    if @groups.any? || @includes.any? || @orders.any? || @joins.any? || any_wheres_other_then_relation?
      return true
    else
      return false
    end
  end

  def any_wheres_other_then_relation?
    if @_previous_model && @_relation && @wheres.length == 1
      looks_like = "`#{@_relation.fetch(:table_name)}`.`#{@_relation.fetch(:foreign_key)}` = '#{@_previous_model.id}'"

      if @wheres.first == looks_like
        return false
      end
    end

    return true
  end

  def autoloaded_on_previous_model?
    if @_previous_model && @_relation
      if @_previous_model.autoloads.include?(@_relation.fetch(:relation_name))
        return true
      end
    end

    return false
  end
end
