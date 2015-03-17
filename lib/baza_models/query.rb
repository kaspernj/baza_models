require "array_enumerator"

class BazaModels::Query
  def initialize(args)
    @args = args
    @model = @args[:model]

    @wheres = []
    @joins = []
    @groups = []
    @orders = []
  end

  def where(args)
    args.each do |key, value|
      @wheres << "`#{@model.table_name}`.`#{key}` = '#{value}'"
    end

    return self
  end

  def to_enum
    ArrayEnumerator.new do |yielder|
      @model.db.query(to_sql).each do |data|
        yielder << @model.new(data)
      end
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
    sql = "SELECT * FROM `#{@model.table_name}` "

    unless @joins.empty?
      @joins.each do |join|
        sql << join.to_sql
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
end
