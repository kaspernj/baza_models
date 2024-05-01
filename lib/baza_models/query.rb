require "array_enumerator"

class BazaModels::Query
  AutoAutoloader.autoload_sub_classes(self, __FILE__)

  include BazaModels::Query::Pagination

  attr_accessor :previous_model, :relation

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
    @offset = args[:offset]
    @orders = args[:orders] || []
    @page = args[:page]
    @per = args[:per]
    @previous_model = args[:previous_model]
    @limit = args[:limit]

    @joins_tracker = {}
  end

  def all
    self
  end

  def any?
    if @db.query(clone.select(:id).limit(1).to_sql).fetch
      true
    else
      false
    end
  end

  def average(column_name)
    query = select("AVG(#{table_sql}.#{column_sql(column_name)}) AS average")
    @db.query(query.to_sql).fetch.fetch(:average).to_f
  end

  def empty?
    !any?
  end

  def ids
    pluck(:id)
  end

  def maximum(column_name)
    query = select("MAX(#{table_sql}.#{column_sql(column_name)}) AS maximum")
    @db.query(query.to_sql).fetch.fetch(:maximum).to_f
  end

  def minimum(column_name)
    query = select("MIN(#{table_sql}.#{column_sql(column_name)}) AS minimum")
    @db.query(query.to_sql).fetch.fetch(:minimum).to_f
  end

  def none?
    !any?
  end

  def count
    if
@previous_model&.new_record?
      autoloaded_cache_or_create.length
    else
      query = clone(selects: [])
        .select("COUNT(*) AS count")
        .limit(nil)
        .offset(nil)

      @db.query(query.to_sql).fetch.fetch(:count)
    end
  end

  def length
    if @previous_model && !any_wheres_other_than_relation? && @previous_model.autoloads[@relation.fetch(:relation_name)]
      @previous_model.autoloads[@relation.fetch(:relation_name)].length
    else
      count
    end
  end

  def size
    # TODO: This should also take counter caching into account
    length
  end

  def pluck(*column_names)
    results = @db.query(select(column_names).to_sql).to_a
    results.map do |result|
      if column_names.length == 1
        result.fetch(column_names.first)
      else
        column_names.map do |column_name|
          result.fetch(column_name)
        end
      end
    end
  end

  def sum(column_name)
    query = select("SUM(#{table_sql}.#{column_sql(column_name)}) AS sum")
    @db.query(query.to_sql).fetch.fetch(:sum).to_f
  end

  def new(attributes)
    raise "No previous model" unless @previous_model
    raise "No relation" unless @relation

    new_sub_model = @model.new(@relation.fetch(:foreign_key) => @previous_model.id)
    new_sub_model.assign_attributes(attributes)
    autoloaded_cache_or_create << new_sub_model

    new_sub_model
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
    elsif select.is_a?(Symbol)
      clone(selects: @selects + ["`#{@model.table_name}`.`#{select}`"])
    else
      clone(selects: @selects + [select])
    end
  end

  def offset(offset)
    clone(offset: offset)
  end

  def limit(limit)
    clone(limit: limit)
  end

  def includes(*names)
    clone(includes: @includes + names)
  end

  def where(*args)
    first_arg = args.first
    new_wheres = @wheres.dup

    if first_arg.is_a?(String)
      new_where = "(#{args.shift})"

      args.each do |arg|
        new_where.sub!("?", @db.quote_value(arg))
      end

      new_wheres << new_where
    elsif first_arg.is_a?(Array)
      str = first_arg.shift

      first_arg.each do |arg|
        if arg.is_a?(Symbol)
          arg = "`#{@model.table_name}`.`#{@db.escape_column(arg)}`"
        elsif arg.is_a?(FalseClass)
          arg = "0"
        elsif arg.is_a?(TrueClass)
          arg = "1"
        else
          arg = @db.quote_value(arg)
        end

        str.sub!("?", arg)
      end

      new_wheres << "(#{str})"
    elsif first_arg == nil
      return Not.new(query: self)
    else
      first_arg.each do |key, value|
        if value.is_a?(Hash)
          value.each do |hash_key, hash_value|
            new_wheres << "`#{key}`.`#{key_convert(hash_key, hash_value)}` #{value_with_mode(value_convert(hash_value))}"
          end
        else
          new_wheres << "`#{@model.table_name}`.`#{key_convert(key, value)}` #{value_with_mode(value_convert(value))}"
        end
      end
    end

    clone(wheres: new_wheres)
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
      clone(groups: @groups + ["`#{@model.table_name}`.`#{name}`"])
    elsif name.is_a?(String)
      clone(groups: @groups + [name])
    else
      raise "Didn't know how to group by that argument: #{name}"
    end
  end

  def order(name)
    if name.is_a?(Symbol)
      clone(orders: @orders + ["`#{@model.table_name}`.`#{name}`"])
    elsif name.is_a?(String)
      clone(orders: @orders + [name])
    else
      raise "Didn't know how to order by that argument: #{name}"
    end
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
      array_enum
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

      array
    end
  end

  def each(&blk)
    to_enum.each(&blk)
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
    clone.where(args).first
  end

  def to_a
    to_enum.to_a
  end

  def to_sql
    BazaModels::Query::SqlGenerator.new(query: self).to_sql
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
    raise "No previous model set" unless @previous_model
    raise "No relation" unless @relation

    if model.persisted?
      model.update_attributes!(@relation.fetch(:foreign_key) => @previous_model.id)
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

  def ransack(params, args = {})
    BazaModels::Ransacker.new(class: @model, params: params, query: self, args: args)
  end

private

  def should_use_autoload?
    !any_mods? && autoloaded_on_previous_model?
  end

  def autoloaded_cache_or_create
    @previous_model.autoloads[@relation.fetch(:relation_name)] ||= []
    autoloaded_cache
  end

  def autoloaded_cache
    @previous_model.autoloads.fetch(@relation.fetch(:relation_name))
  end

  def any_mods?
    @groups.any? || @includes.any? || @orders.any? || @joins.any? || any_wheres_other_than_relation?
  end

  def any_wheres_other_than_relation?
    if @previous_model && @relation && @wheres.length == 1
      looks_like = "`#{@relation.fetch(:table_name)}`.`#{@relation.fetch(:foreign_key)}` = #{@previous_model.id}"

      return false if @wheres.first == looks_like
    end

    true
  end

  def autoloaded_on_previous_model?
    return true if @previous_model && @relation && @previous_model.autoloads.include?(@relation.fetch(:relation_name))

    false
  end

  def clone(args = {})
    BazaModels::Query.new({
      model: @model,
      selects: @selects,
      wheres: @wheres,
      joins: @joins.dup,
      includes: @includes,
      groups: @groups,
      offset: @offset,
      orders: @orders,
      page: @page,
      per: @per,
      previous_model: @previous_model,
      limit: @limit
    }.merge(args))
  end

  def key_convert(key, value)
    return "#{key}_id" if value.is_a?(BazaModels::Model)

    key
  end

  def value_convert(value)
    return value.id if value.is_a?(BazaModels::Model)

    value
  end

  def value_with_mode(value)
    if value.is_a?(Array)
      sql = "IN ("

      first = true
      value.each do |val_i|
        if first
          first = false
        else
          sql << ", " unless first
        end

        sql << @db.quote_value(val_i)
      end

      sql << ")"
      sql
    elsif value == nil
      "IS NULL"
    else
      "= #{@db.quote_value(value)}"
    end
  end

  def table_sql
    @table_sql ||= "#{@db.sep_table}#{@db.escape_table(@model.table_name)}#{@db.sep_table}"
  end

  def column_sql(column_name)
    "#{@db.sep_col}#{@db.escape_column(column_name)}#{@db.sep_col}"
  end

  def method_missing(method_name, *args, &blk)
    return super unless @model

    scopes = @model.instance_variable_get(:@scopes)
    return super if !scopes || !scopes.key?(method_name)

    block = scopes.fetch(method_name).fetch(:blk)
    instance_exec(*args, &block)
  end
end
