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
    self
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
    if @_previous_model && @_previous_model.new_record?
      return autoloaded_cache_or_create.length
    else
      query = clone

      query.instance_variable_set(:@selects, [])
      query = clone.select("COUNT(*) AS count")

      @db.query(query.to_sql).fetch.fetch(:count)
    end
  end

  def length
    count
  end

  def find(id)
    model = clone.where(id: id).limit(1).to_enum.first

    if model
      model.__send__(:fire_callbacks, :after_find)
    else
      raise BazaModels::Errors::RecordNotFound
    end

    model
  end

  def find_by(args)
    clone.where(args).limit(1).to_enum.first
  end

  def first
    return autoloaded_cache.first if should_use_autoload?

    query = clone.limit(1)

    orders = query.instance_variable_get(:@orders)
    query = query.order(:id) if orders.empty?

    query.to_enum.first
  end

  def last
    return autoloaded_cache.last if should_use_autoload?

    query = clone.limit(1)

    orders = query.instance_variable_get(:@orders)
    query = query.order(:id) if orders.empty?

    query.reverse_order.to_enum.first
  end

  def select(select = nil, &blk)
    if !select && blk
      to_enum.select(&blk)
    else
      if select.is_a?(Symbol)
        @selects << "`#{@model.table_name}`.`#{select}`"
      else
        @selects << select
      end

      self
    end
  end

  def offset(offset)
    @offset = offset
    self
  end

  def limit(limit)
    @limit = limit
    self
  end

  def includes(name)
    @includes << name
    self
  end

  def where(args = nil)
    if args.is_a?(String)
      @wheres << "(#{args})"
    elsif args.is_a?(Array)
      str = args.shift

      args.each do |arg|
        if arg.is_a?(Symbol)
          arg = "`#{@model.table_name}`.`#{@db.escape_column(arg)}`"
        elsif arg.is_a?(FalseClass)
          arg = "0"
        elsif arg.is_a?(TrueClass)
          arg = "1"
        else
          arg = "'#{@db.esc(arg)}'"
        end

        str.sub!("?", arg)
      end

      @wheres << "(#{str})"
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

    self
  end

  def joins(*arguments)
    BazaModels::Query::Inspector.new(
      query: self,
      model: @model,
      argument: arguments,
      joins: @joins,
      joins_tracker: @joins_tracker
    ).execute

    self
  end

  def group(name)
    if name.is_a?(Symbol)
      @groups << "`#{@model.table_name}`.`#{name}`"
    elsif name.is_a?(String)
      @groups << name
    else
      raise "Didn't know how to group by that argument: #{name}"
    end

    self
  end

  def order(name)
    if name.is_a?(Symbol)
      @orders << "`#{@model.table_name}`.`#{name}`"
    elsif name.is_a?(String)
      @orders << name
    else
      raise "Didn't know how to order by that argument: #{name}"
    end

    self
  end

  def reverse_order
    @reverse_order = true
    self
  end

  def map(&blk)
    to_enum.map(&blk)
  end

  def to_enum
    return autoloaded_cache if should_use_autoload?

    array_enum = ArrayEnumerator.new do |yielder|
      @db.query(to_sql).each do |data|
        yielder << @model.new(data, init: true)
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

  def find_first(args)
    where(args).first
  end

  def to_a
    to_enum.to_a
  end

  def to_sql
    sql = "SELECT "

    if @selects.empty?
      sql << "`#{@model.table_name}`.*"
    else
      sql << @selects.join(", ")
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

    sql.strip
  end

  def destroy_all
    each(&:destroy!)
  end

  def to_s
    "#<BazaModels::Query class=#{@model.name} wheres=#{@wheres}>"
  end

  def inspect
    to_s
  end

  def <<(model)
    raise "No previous model set" unless @_previous_model
    raise "No relation" unless @_relation

    if model.persisted?
      model.update_attributes!(@_relation.fetch(:foreign_key) => @_previous_model.id)
    else
      autoloaded_cache_or_create << model
    end

    self
  end

  # CanCan supports
  def accessible_by(ability, action = :index)
    ability.model_adapter(self, action).database_records
  end

  def <=(_other)
    false
  end

  def sanitize_sql(value)
    return value if value.is_a?(Array) || value.is_a?(Integer) || value.is_a?(Integer)
    "'#{@db.esc(value)}'"
  end

  def page(some_page)
    some_page ||= 1
    offset = (some_page.to_i - 1) * per

    clone.offset(offset).limit(30)
  end

  def per
    @per ||= 30
  end

  def total_pages
    pages_count = (count.to_f / @per.to_f)
    pages_count = 1 if pages_count.nan? || pages_count == Float::INFINITY
    pages_count = pages_count.to_i
    pages_count = 1 if pages_count == 0
    pages_count
  end

private

  def should_use_autoload?
    !any_mods? && autoloaded_on_previous_model?
  end

  def autoloaded_cache_or_create
    @_previous_model.autoloads[@_relation.fetch(:relation_name)] ||= []
    autoloaded_cache
  end

  def autoloaded_cache
    @_previous_model.autoloads.fetch(@_relation.fetch(:relation_name))
  end

  def any_mods?
    @groups.any? || @includes.any? || @orders.any? || @joins.any? || any_wheres_other_than_relation?
  end

  def any_wheres_other_than_relation?
    if @_previous_model && @_relation && @wheres.length == 1
      looks_like = "`#{@_relation.fetch(:table_name)}`.`#{@_relation.fetch(:foreign_key)}` = '#{@_previous_model.id}'"

      return false if @wheres.first == looks_like
    end

    true
  end

  def autoloaded_on_previous_model?
    if @_previous_model && @_relation
      return true if @_previous_model.autoloads.include?(@_relation.fetch(:relation_name))
    end

    false
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
