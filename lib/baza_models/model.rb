require "string-cases"

class BazaModels::Model
  def initialize(data = {})
    self.class.init_model unless self.class.model_initialized?

    @data = data
    @errors = {}

    if data[:id]
      @new_record = true
    else
      @new_record = false
    end
  end

  def new_record?
    return @new_record
  end

  def self.db
    @db ||= BazaModels.primary_db
  end

  def table_name
    @table_name ||= self.class.table_name
  end

  def self.table_name
    @table_name ||= "#{StringCases.camel_to_snake(name)}s"
  end

  def self.init_model
    @table = db.tables[table_name]
    @table.columns.each do |column_name, column|
      init_attribute_from_column(column)
    end

    @model_initialized = true
  end

  def self.init_attribute_from_column(column)
    define_method(column.name) do
      return @data[column.name]
    end

    define_method("#{column.name}=") do |new_value|
      @data[column.name] = new_value
    end
  end

  def self.model_initialized?
    return @model_initialized
  end

  def self.validates(attribute_name, args)
    args.each do |validator_name, validator_args|
      validator_camel_name = StringCases.snake_to_camel(validator_name)
      class_name = "#{validator_camel_name}Validator"

      @validators ||= {}
      @validators[attribute_name] ||= Array.new
      @validators[attribute_name] << {
        validator: BazaModels::Validators.const_get(class_name)
      }
    end
  end

  def save
    raise "stub!"
  end

  def destroy
    raise "stub!"
  end

  def destroy!
    raise "stub!"
  end

  def update_attributes(attributes)
    raise "stub!"
  end

  def update_attributes!(attributes)
    unless update_attributes(attributes)
      raise BazaModels::Errors::InvalidRecord, errors
    end
  end

  def errors
    raise "stub!"
  end

  def valid?
    raise "stub!"
  end
end
