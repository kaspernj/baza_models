require "string-cases"

class BazaModels::Model
  AutoAutoloader.autoload_sub_classes(self, __FILE__)

  include BelongsToRelations
  include Delegation
  include CustomValidations
  include HasManyRelations
  include HasOneRelations
  include Manipulation
  include Queries
  include Scopes
  include TranslationFunctionality
  include Validations

  attr_accessor :data, :db
  attr_reader :changes, :errors

  # Define all callback methods.
  CALLBACK_TYPES = [
    :after_initialize, :after_find, :before_update, :after_update,
    :before_create, :after_create, :before_save, :after_save, :before_destroy, :after_destroy,
    :before_validation, :after_validation, :before_validation_on_create, :after_validation_on_create,
    :before_validation_on_update, :after_validation_on_update
  ]

  CALLBACK_TYPES.each do |callback_type|
    # rubocop:disable Style/ClassVars
    @@callbacks ||= {}
    # rubocop:enable Style/ClassVars

    @@callbacks[callback_type] = {}
    callbacks = @@callbacks

    (class << self; self; end).__send__(:define_method, callback_type) do |method_name = nil, *args, &blk|
      callbacks[callback_type][name] ||= []
      callbacks[callback_type][name] << {
        block: blk,
        method_name: method_name,
        args: args
      }
    end
  end

  QUERY_METHODS = [
    :all, :any?, :empty?, :none?, :count, :find, :first, :find_first, :last, :length, :select, :includes,
    :joins, :group, :where, :order, :limit, :to_a, :accessible_by
  ]
  QUERY_METHODS.each do |query_method|
    (class << self; self; end).__send__(:define_method, query_method) do |*args, &blk|
      BazaModels::Query.new(model: self).__send__(query_method, *args, &blk)
    end
  end

  def initialize(data = {}, args = {})
    self.class.init_model unless self.class.model_initialized?

    reset_errors
    @changes = {}

    if args[:init]
      @data = self.class.__blank_attributes.merge(real_attributes(data))
    else
      @data = self.class.__blank_attributes.clone
      @changes.merge!(real_attributes(data))
    end

    if @data[:id]
      @new_record = false
    else
      @new_record = true
      fire_callbacks(:after_initialize)
    end
  end

  # rubocop:disable Style/TrivialAccessors
  def new_record?
    # rubocop:enable Style/TrivialAccessors
    @new_record
  end

  def persisted?
    !new_record?
  end

  def db
    return @db if @db
    @db ||= self.class.db
  end

  attr_writer :db

  def self.db
    @db = nil if @db && @db.closed?
    return @db if @db
    @db ||= BazaModels.primary_db
    raise "No Baza database has been configured" unless @db
    @db
  end

  def self.to_adapter
    BazaModels::BazaOrmAdapter.new(class: self)
  end

  def self.transaction(&blk)
    @db.transaction(&blk)
  end

  class << self
    attr_writer :db, :table_name
  end

  attr_writer :table_name

  def autoloads
    @autoloads ||= {}
    @autoloads
  end

  def table_name
    @table_name ||= self.class.table_name
  end

  def self.table_name
    @table_name ||= "#{StringCases.camel_to_snake(name.gsub("::", ""))}s"
  end

  def self.relationships
    @relationships ||= {}
  end

  def to_model
    self
  end

  def self.init_model
    @table = db.tables[table_name]

    @__blank_attributes ||= {}

    @table.columns do |column|
      init_attribute_from_column(column)
      @__blank_attributes[column.name.to_sym] = nil
    end

    @model_initialized = true
  end

  def id
    @data.fetch(:id)
  end

  def to_param
    id.to_s if id
  end

  def to_key
    if new_record?
      nil
    else
      [id]
    end
  end

  def reload
    @data = db.single(table_name, {id: id}, limit: 1)
    raise BazaModels::Errors::RecordNotFound unless @data
    @changes = {}
    self
  end

  def to_s
    if new_record?
      "#<#{self.class.name} new!>"
    else
      "#<#{self.class.name} id=#{id}>"
    end
  end

  def inspect
    data_str = ""
    @data.each do |key, value|
      if @changes.key?(key)
        value_to_use = @changes.fetch(key)
      else
        value_to_use = value
      end

      data_str << " " unless data_str.empty?
      data_str << "#{key}=\"#{value_to_use}\""
    end

    "#<#{self.class.name} #{data_str}>"
  end

  def ==(other)
    return false unless self.class == other.class

    if new_record? && other.new_record?
      return merged_data == other.__send__(:merged_data)
    else
      return id == other.id
    end
  end

  # rubocop:disable Style/PredicateName
  def has_attribute?(name)
    # rubocop:enable Style/PredicateName
    self.class.column_names.include?(name.to_s)
  end

  def self.column_names
    @column_names ||= __blank_attributes.keys.map(&:to_s)
  end

  def self.ransack(params)
    BazaModels::Ransacker.new(class: self, params: params)
  end

  def [](key)
    read_attribute(key)
  end

  def []=(key, value)
    write_attribute(key, value)
  end

  def read_attribute(attribute_name)
    return @changes.fetch(attribute_name) if @changes.key?(attribute_name)
    @data.fetch(attribute_name)
  end

  def write_attribute(attribute_name, value)
    @changes[attribute_name] = value
  end

  def changed?
    changed = false
    @changes.each do |key, value|
      next if @data.fetch(key) == value
      changed = true
      break
    end

    changed
  end

protected

  class << self
    attr_reader :__blank_attributes
  end

  # rubocop:disable Style/TrivialAccessors
  def self.model_initialized?
    # rubocop:enable Style/TrivialAccessors
    @model_initialized
  end

  def self.init_attribute_from_column(column)
    column_name = column.name.to_sym

    define_method(column_name) do
      read_attribute(column_name)
    end

    define_method("#{column_name}_was") do
      return @data.fetch(column_name)
    end

    define_method("#{column_name}=") do |new_value|
      write_attribute(column_name, new_value)
    end

    define_method("#{column_name}?") do
      !@data.fetch(column_name).to_s.strip.empty?
    end

    define_method("#{column_name}_changed?") do
      if @changes.key?(column_name) && @changes.fetch(column_name) != @data.fetch(column_name)
        true
      else
        false
      end
    end
  end

  def reset_errors
    @errors = BazaModels::Errors.new
  end

  def fire_callbacks(name)
    return if !@@callbacks[name] || !@@callbacks[name][self.class.name]

    @@callbacks[name][self.class.name].each do |callback_data|
      if callback_data[:block]
        instance_eval(&callback_data.fetch(:block))
      elsif callback_data[:method_name]
        __send__(callback_data[:method_name], *callback_data.fetch(:args))
      else
        raise "Didn't know how to perform callbacks for #{name}"
      end
    end
  end

  def merged_data
    @data.merge(@changes)
  end

  # Converts attributes like "user" to "user_id" and so on.
  def real_attributes(attributes)
    new_attributes = {}
    attributes.each do |attribute_name, attribute_value|
      belongs_to_relations = self.class.instance_variable_get(:@belongs_to_relations)

      if belongs_to_relations
        belongs_to_relations.each do |relation|
          if attribute_name.to_s == relation[:relation_name].to_s
            attribute_name = :"#{attribute_name}_id"
            attribute_value = attribute_value.id
          end
        end
      end

      unless has_attribute?(attribute_name)
        set_method_name = "#{attribute_name}="

        if respond_to?(set_method_name)
          __send__(set_method_name, attribute_value)
          next
        else
          raise "Unknown attribute: #{attribute_name}"
        end
      end

      new_attributes[attribute_name.to_sym] = attribute_value
    end

    new_attributes
  end
end
