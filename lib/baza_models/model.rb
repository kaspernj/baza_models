require "string-cases"

class BazaModels::Model
  path = "#{File.dirname(__FILE__)}/model"

  autoload :BelongsToRelations, "#{path}/belongs_to_relations"
  autoload :CustomValidations, "#{path}/custom_validations"
  autoload :Delegation, "#{path}/delegation"
  autoload :HasManyRelations, "#{path}/has_many_relations"
  autoload :HasOneRelations, "#{path}/has_one_relations"
  autoload :Manipulation, "#{path}/manipulation"
  autoload :Queries, "#{path}/queries"
  autoload :Scopes, "#{path}/scopes"
  autoload :Validations, "#{path}/validations"

  include BelongsToRelations
  include Delegation
  include CustomValidations
  include HasManyRelations
  include HasOneRelations
  include Manipulation
  include Queries
  include Scopes
  include Validations

  attr_accessor :data, :db
  attr_reader :changes, :errors

  # Define all callback methods.
  CALLBACK_TYPES = [:before_create, :after_create, :before_save, :after_save, :before_destroy, :after_destroy,
    :before_validation, :after_validation, :before_validation_on_create, :after_validation_on_create,
    :before_validation_on_update, :after_validation_on_update]

  CALLBACK_TYPES.each do |callback_type|
    @@callbacks ||= {}
    @@callbacks[callback_type] = {}
    callbacks = @@callbacks

    (class << self; self; end).__send__(:define_method, callback_type) do |method_name, *args, &blk|
      callbacks[callback_type][self.name] ||= []
      callbacks[callback_type][self.name] << {
        block: blk,
        method_name: method_name,
        args: args
      }
    end
  end


  QUERY_METHODS = [:all, :any?, :empty?, :none?, :count, :first, :last, :length, :select, :includes, :joins, :group, :where, :order, :limit]
  QUERY_METHODS.each do |query_method|
    (class << self; self; end).__send__(:define_method, query_method) do |*args, &blk|
      BazaModels::Query.new(model: self).__send__(query_method, *args, &blk)
    end
  end


  def initialize(data = {})
    self.class.init_model unless self.class.model_initialized?

    @data = self.class.__blank_attributes.merge(real_attributes(data))

    @changes = {}

    reset_errors

    if @data[:id]
      @new_record = false
    else
      @new_record = true
    end
  end

  def new_record?
    return @new_record
  end

  def persisted?
    !new_record?
  end

  def db
    return @db if @db
    return self.class.db
  end

  def db=(db)
    @db = db
  end

  def self.db
    return @db if @db
    return BazaModels.primary_db
  end

  def self.db=(db)
    @db = db
  end

  def autoloads
    @autoloads ||= {}
    return @autoloads
  end

  def self.relationships
    return @relationships
  end

  def table_name
    @table_name ||= self.class.table_name
  end

  def table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{StringCases.camel_to_snake(name.gsub("::", ""))}s"
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.init_model
    @table = db.tables[table_name]

    @__blank_attributes ||= {}

    @table.columns.each do |column_name, column|
      init_attribute_from_column(column)
      @__blank_attributes[column_name] = nil
    end

    @model_initialized = true
  end

  def id
    return @data.fetch(:id)
  end

  def to_param
    return id
  end

  def reload
    @data = db.single(table_name, {id: id}, limit: 1)
    raise BazaModels::Errors::RecordNotFound unless @data
    @changes = {}
    return self
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

  def ==(another_model)
    return false unless self.class == another_model.class

    if new_record? && another_model.new_record?
      return merged_data == another_model.__send__(:merged_data)
    else
      return id == another_model.id
    end
  end

  def has_attribute?(name)
    self.class.__blank_attributes.keys.map { |key| key.to_s }.include?(name.to_s)
  end

protected

  def self.__blank_attributes
    return @__blank_attributes
  end

  def self.model_initialized?
    return @model_initialized
  end

  def self.init_attribute_from_column(column)
    column_name = column.name.to_sym

    define_method(column_name) do
      return @changes.fetch(column_name) if @changes.key?(column_name)
      return @data.fetch(column_name)
    end

    define_method("#{column_name}_was") do
      return @data.fetch(column_name)
    end

    define_method("#{column_name}=") do |new_value|
      @changes[column_name] = new_value
    end

    define_method("#{column_name}?") do
      !@data.fetch(column_name).to_s.strip.empty?
    end
  end

  def reset_errors
    @errors = BazaModels::Errors.new
  end

  def fire_callbacks(name)
    if @@callbacks[name] && @@callbacks[name][self.class.name]
      @@callbacks[name][self.class.name].each do |callback_data|
        if callback_data[:block]
          callback_data[:block].call(*callback_data.fetch(:args))
        elsif callback_data[:method_name]
          __send__(callback_data[:method_name], *callback_data.fetch(:args))
        else
          raise "Didn't know how to perform callbacks for #{name}"
        end
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
      set = false
      belongs_to_relations = self.class.instance_variable_get(:@belongs_to_relations)

      if belongs_to_relations
        belongs_to_relations.each do |relation|
          if attribute_name.to_s == relation[:relation_name].to_s
            new_attributes[:"#{attribute_name}_id"] = attribute_value.id
            set = true
          end
        end
      end

      new_attributes[attribute_name] = attribute_value unless set
    end

    return new_attributes
  end
end
