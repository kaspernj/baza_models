require "string-cases"

class BazaModels::Model
  path = "#{File.dirname(__FILE__)}/model"
  autoload :BelongsToRelations, "#{path}/belongs_to_relations"
  autoload :HasManyRelations, "#{path}/has_many_relations"

  include BelongsToRelations
  include HasManyRelations

  attr_accessor :db
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


  QUERY_METHODS = [:where]
  QUERY_METHODS.each do |query_method|
    (class << self; self; end).__send__(:define_method, query_method) do |*args, &blk|
      BazaModels::Query.new(model: self).__send__(query_method, *args, &blk)
    end
  end


  def initialize(data = {})
    self.class.init_model unless self.class.model_initialized?

    @data = real_attributes(data)
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
    @table.columns.each do |column_name, column|
      init_attribute_from_column(column)
    end

    @model_initialized = true
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
  end

  def self.model_initialized?
    return @model_initialized
  end

  def self.validates(attribute_name, args)
    args.each do |validator_name, validator_args|
      validator_camel_name = StringCases.snake_to_camel(validator_name)
      class_name = "#{validator_camel_name}Validator"

      @@validators ||= {}
      @@validators[attribute_name] ||= []
      @@validators[attribute_name] << BazaModels::Validators.const_get(class_name).new(attribute_name, args)
    end
  end

  def self.find(id)
    row = db.select(table_name, {id: id}, limit: 1).fetch
    raise BazaModels::Errors::RecordNotFound, "Record not found by ID: #{id}" unless row
    return new(row)
  end

  def self.find_by(where_hash)
    row = db.select(table_name, where_hash, limit: 1).fetch
    raise BazaModels::Errors::RecordNotFound, "Record not found by ID: #{id}" unless row
    return new(row)
  end

  def id
    return @data[:id]
  end

  def save
    if valid?
      new_record = new_record?
      fire_callbacks(:before_save)

      if new_record
        fire_callbacks(:before_create)
        @data[:id] = db.insert(table_name, @data.merge(@changes), return_id: true)
      else
        db.update(table_name, @changes, id: id)
      end

      @changes = {}
      @new_record = false
      reload

      fire_callbacks(:after_save)
      fire_callbacks(:after_create) if new_record

      return true
    else
      return false
    end
  end

  def save!
    if save
      return true
    else
      raise BazaModels::Errors::InvalidRecord
    end
  end

  def reload
    @data = db.select(table_name, {id: id}, limit: 1).fetch
    @changes = {}
    return self
  end

  def destroy
    if new_record?
      errors.add(:base, "cannot destroy new record")
      return false
    else
      fire_callbacks(:before_destroy)
      db.delete(table_name, id: id)
      fire_callbacks(:after_destroy)
      return true
    end
  end

  def destroy!
    raise BazaModels::Errors::InvalidRecord, @errors.full_messages.join(". ") unless destroy
  end

  def assign_attributes(attributes)
    @changes.merge!(real_attributes(attributes))
  end

  def update_attributes(attributes)
    assign_attributes(attributes)
    return save
  end

  def update_attributes!(attributes)
    unless update_attributes(attributes)
      raise BazaModels::Errors::InvalidRecord, @errors.full_messages.join(". ")
    end
  end

  def valid?
    fire_callbacks(:before_validation)

    if new_record?
      fire_callbacks(:before_validation_on_create)
    else
      fire_callbacks(:before_validation_on_update)
    end

    reset_errors

    merged_data = @data.merge(@changes)
    merged_data.each do |attribute_name, attribute_value|
      next unless @@validators.key?(attribute_name)

      @@validators[attribute_name].each do |validator|
        validator.validate(self, attribute_value)
      end
    end

    fire_callbacks(:after_validation)

    if new_record?
      fire_callbacks(:after_validation_on_create)
    else
      fire_callbacks(:after_validation_on_update)
    end

    return @errors.empty?
  end

  def to_s
    if new_record?
      "#<#{self.class.name} new!>"
    else
      "#<#{self.class.name} id=#{id}>"
    end
  end

  def inspect
    if new_record?
      "#<#{self.class.name} new! data=#{@data.merge(@changes)}>"
    else
      "#<#{self.class.name} id=#{id} data=#{@data.merge(@changes)}>"
    end
  end

  def ==(another_model)
    return false unless self.class == another_model.class

    if new_record? && another_model.new_record?
      return merged_data == another_model.__send__(:merged_data)
    else
      return id == another_model.id
    end
  end

protected

  def reset_errors
    @errors = BazaModels::Errors.new
  end

  def fire_callbacks(name)
    if @@callbacks[name] && @@callbacks[name][self.class.name]
      @@callbacks[name][self.class.name].each do |callback_data|
        if callback_data[:block]
          callback_data[:block].call(*callback_data[:args])
        elsif callback_data[:method_name]
          __send__(callback_data[:method_name], *callback_data[:args])
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
            new_attributes["#{attribute_name}_id"] = attribute_value.id
            set = true
          end
        end
      end

      new_attributes[attribute_name] = attribute_value unless set
    end

    return new_attributes
  end
end
