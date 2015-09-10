require "array_enumerator"

class BazaModels::Query
  path = "#{File.dirname(__FILE__)}/query"

  autoload :Inspector, "#{path}/inspector"
  autoload :Not, "#{path}/not"

  attr_accessor :_previous_model, :_relation

  def initialize(args)
    @args = args
    @model = @args[:model]
    @db = @model.db

    raise "No database?" unless @db

    @selects = args[:selects] || []
    @wheres = args[:wheres] || []
    @includes = args[:includes] || []
    @joins = args[:joins] || []
    @groups = args[:groups] || []
    @orders = args[:orders] || []
    @limit = args[:limit]

    @joins_tracker = {}
  end

  def all
    return self
  end

  def any?
    if @db.query(clone.select(:id).limit(1).to_sql).fetch
      return true
    else
      return false
    end
  end

  def empty?
    !any?
  end

  def none?
    !any?
  end

  def count
    query = clone

    query.instance_variable_set(:@selects, [])
    query = clone.select("COUNT(*) AS count")

    return @db.query(query.to_sql).fetch.fetch(:count)
  end

  def length
    count
  end

  def find(id)
    return clone.where(id: id).limit(1).to_enum.first
  end

  def first
    query = clone.limit(1)

    orders = query.instance_variable_get(:@orders)
    query = query.order(:id) if orders.empty?

    return query.to_enum.first
  end

  def last
    query = clone.limit(1)

    orders = query.instance_variable_get(:@orders)
    query = query.order(:id) if orders.empty?

    return query.reverse_order.to_enum.first
  end

  def select(select)
    if select.is_a?(Symbol)
      @selects << "`#{@model.table_name}`.`#{select}`"
    else
      @selects << select
    end

    return self
  end

  def offset(offset)
    @offset = offset
    return self
  end

  def limit(limit)
    @limit = limit
    return self
  end

  def includes(name)
    @includes << name
    return self
  end

  def where(args = nil)
    if args.is_a?(String)
      @wheres << "(#{args})"
    elsif args == nil
      return Not.new(query: self)
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

  def joins(*arguments)
    BazaModels::Query::Inspector.new(
      query: self,
      model: @model,
      argument: arguments,
      joins: @joins,
      joins_tracker: @joins_tracker
    ).execute

    return self
  end

  def group(name)
    if name.is_a?(Symbol)
      @groups << "`#{@model.table_name}`.`#{name}`"
    elsif name.is_a?(String)
      @groups << name
    else
      raise "Didn't know how to group by that argument: #{name}"
    end

    return self
  end

  def order(name)
    if name.is_a?(Symbol)
      @orders << "`#{@model.table_name}`.`#{name}`"
    elsif name.is_a?(String)
      @orders << name
    else
      raise "Didn't know how to order by that argument: #{name}"
    end

    return self
  end

  def reverse_order
    @reverse_order = true
    return self
  end

  def to_enum
    if !any_mods? && autoloaded_on_previous_model?
      return @_previous_model.autoloads.fetch(@_relation.fetch(:relation_name))
    end

    array_enum = ArrayEnumerator.new do |yielder|
      @db.query(to_sql).each do |data|
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

  def find_each
    query = clone
    query.instance_variable_set(:@order, [])
    query.instance_variable_set(:@limit, nil)
    query = query.order(:id)

    offset = 0

    loop do
      query = query.offset(offset, 1000)
      offset += 1000

      count = 0
      query.each do |model|
        yield model
        count += 1
      end

      break if count == 0
    end
  end

  def to_a
    to_enum.to_a
  end

  def to_sql
    sql = "SELECT "

    if @selects.empty?
      sql << "`#{@model.table_name}`.*"
    else
      sql << @selects.join(', ')
    end

    sql << " FROM `#{@model.table_name}`"

    unless @joins.empty?
      @joins.each do |join|
        sql << " #{join}"
      end
    end

    unless @wheres.empty?
      sql << " WHERE "

      first = true
      @wheres.each do |where|
        if first == true
          first = false
        else
          sql << " AND "
        end

        sql << where
      end
    end

    unless @groups.empty?
      sql << " GROUP BY "

      first = true
      @groups.each do |group|
        if first
          first = false
        else
          sql << ", "
        end

        sql << group
      end
    end

    unless @orders.empty?
      sql << " ORDER BY "

      first = true
      @orders.each do |order|
        if first
          first = false
        else
          sql << ", "
        end

        if @reverse_order
          if order.match(/\s+desc/i)
            order = order.gsub(/\s+desc/i, " ASC")
          elsif order.match(/\s+asc/i)
            order = order.gsub(/\s+asc/i, " DESC")
          else
            order = "#{order} DESC"
          end
        end

        sql << order
      end
    end

    if @limit && @offset
      sql << " LIMIT #{@offset.to_i}, #{@limit.to_i}"
    elsif @limit
      sql << " LIMIT #{@limit.to_i}"
    end

    return sql.strip
  end

  def destroy_all
    each do |model|
      model.destroy!
    end
  end

  def to_s
    "#<BazaModels::Query class=#{@model.name} wheres=#{@wheres}>"
  end

  def inspect
    to_s
  end

private

  def any_mods?
    if @groups.any? || @includes.any? || @orders.any? || @joins.any? || any_wheres_other_than_relation?
      return true
    else
      return false
    end
  end

  def any_wheres_other_than_relation?
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

  def clone
    BazaModels::Query.new(
      model: @model,
      selects: @selects.dup,
      wheres: @wheres.dup,
      joins: @joins.dup,
      includes: @includes.dup,
      groups: @groups.dup,
      orders: @orders.dup,
      limit: @limit
    )
  end
end
