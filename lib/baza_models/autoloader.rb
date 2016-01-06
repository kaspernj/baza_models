class BazaModels::Autoloader
  def initialize(args)
    @models = args.fetch(:models)
    @model_class = @models.first.class
    @autoloads = args.fetch(:autoloads)
    @db = args.fetch(:db)
    @debug = args[:debug]

    debug "Autoloading #{@autoloads} on #{@model_class.name} with ID's: #{@models.map(&:id)}" if @debug
  end

  def autoload
    autoload_argument(@autoloads)
  end

private

  def debug(msg)
    print "#{msg}\n" if @debug
  end

  def model_ids
    @model_ids ||= @models.map(&:id)
  end

  def autoload_argument(autoload)
    if autoload.is_a?(Hash)
      autoload_hash(autoload)
    elsif autoload.is_a?(Array)
      autoload_array(autoload)
    elsif autoload.is_a?(Symbol)
      autoload_symbol(autoload)
    else
      raise "Didn't know what to do with autoload: #{autoload} (#{autoload.class.name})"
    end
  end

  def autoload_array(autoload)
    autoload.each do |autoload_i|
      autoload_argument(autoload_i)
    end
  end

  def autoload_hash(autoload)
    autoload.each do |autoload_key, autoload_value|
      result = autoload_symbol(autoload_key)
      next if result.fetch(:models).empty?

      autoloader = BazaModels::Autoloader.new(
        models: result.fetch(:models),
        autoloads: autoload_value,
        db: @db,
        debug: @debug
      )
      autoloader.autoload
    end
  end

  def autoload_symbol(autoload)
    relation = @model_class.relationships.fetch(autoload)

    if relation.fetch(:type) == :has_many
      autoload_has_many(autoload, relation)
    elsif relation.fetch(:type) == :belongs_to
      autoload_belongs_to(autoload, relation)
    elsif relation.fetch(:type) == :has_one
      autoload_has_one(autoload, relation)
    else
      raise "Unknown relation type: #{relation.fetch(:type)}"
    end
  end

  def autoload_belongs_to(autoload_name, relation)
    result = {models: []}

    model_id_mappings = {}
    model_ids = []

    @models.each do |model|
      key = model.data.fetch(relation.fetch(:foreign_key))
      next if model_id_mappings.key?(key)

      model_ids << key
      model_id_mappings[key] = model.id
    end

    @db.select(relation.fetch(:table_name), id: model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data, init: true)

      orig_model_id = model_id_mappings.fetch(model_data.fetch(:id))
      orig_model = @models.detect { |array_model| array_model.id == orig_model_id }
      orig_model.autoloads[autoload_name] ||= model

      result.fetch(:models) << model
    end

    result
  end

  def autoload_has_many(autoload_name, relation)
    result = {models: []}

    @db.select(relation.fetch(:table_name), relation.fetch(:foreign_key) => model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data, init: true)

      orig_model_id = model_data.fetch(relation.fetch(:foreign_key).to_sym)
      orig_model = @models.detect { |array_model| array_model.id == orig_model_id }

      orig_model.autoloads[autoload_name] ||= []
      orig_model.autoloads[autoload_name] << model

      result.fetch(:models) << model
    end

    result
  end

  def autoload_has_one(autoload_name, relation)
    result = {models: []}

    @db.select(relation.fetch(:table_name), relation.fetch(:foreign_key) => model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data, init: true)

      orig_model_id = model_data.fetch(relation.fetch(:foreign_key))
      orig_model = @models.detect { |array_model| array_model.id == orig_model_id }

      raise "Already autoloaded?" if orig_model.autoloads.key?(autoload_name)
      orig_model.autoloads[autoload_name] = model

      result.fetch(:models) << model
    end

    result
  end
end
