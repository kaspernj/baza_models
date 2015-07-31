require "array_enumerator"

class BazaModels::Query
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
    array_enum = ArrayEnumerator.new do |yielder|
      @model.db.query(to_sql).each do |data|
        yielder << @model.new(data)
      end
    end

    if @includes.empty?
      return array_enum
    else
      array = array_enum.to_a
      model_ids = array.map { |model| model.id }

      @includes.each do |include_name|
        relation = @model.relationships.fetch(include_name)

        ids = @db.query("SELECT `#{relation[:table_name]}`.`id` FROM `#{relation[:table_name]}` WHERE `id` IN (#{model_ids.join(',')})").to_a
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
end
