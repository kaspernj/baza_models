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

      result_user = result.fetch(:models).first

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
    foreign_key = relation.fetch(:foreign_key)

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
    sql = "SELECT `#{@model_class.table_name}`.`#{relation.fetch(:foreign_key)}` FROM `#{@model_class.table_name}` WHERE `id` IN (#{model_ids.join(',')})"
    ids = @db.query(sql).to_a.map { |data| data.fetch(relation.fetch(:foreign_key)) }

    result = {models: []}

    model_id_mappings = {}
    @models.each do |model|
      @model_ids << model.id
      model_id_mappings[model.data.fetch(relation.fetch(:foreign_key))] = model.id
    end

    @db.select(relation.fetch(:table_name), id: model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data)

      orig_model_id = model_id_mappings.fetch(model_data.fetch(:id))
      orig_model = @models.detect { |array_model| array_model.id == orig_model_id }
      orig_model.autoloads[autoload_name] ||= model

      result.fetch(:models) << model
    end

    return result
  end

  def autoload_has_many(autoload_name, relation)
    result = {models: []}

    @db.select(relation.fetch(:table_name), relation.fetch(:foreign_key) => model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data)

      orig_model_id = model_data.fetch(relation.fetch(:foreign_key))
      orig_model = @models.detect { |array_model| array_model.id == orig_model_id }

      orig_model.autoloads[autoload_name] ||= []
      orig_model.autoloads[autoload_name] << model

      result.fetch(:models) << model
    end

    return result
  end

  def autoload_has_one(autoload_name, relation)
    result = {models: []}

    @db.select(relation.fetch(:table_name), relation.fetch(:foreign_key) => model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data)

      orig_model_id = model_data.fetch(relation.fetch(:foreign_key))
      orig_model = @models.detect { |array_model| array_model.id == orig_model_id }
      raise "Already autoloaded?" if orig_model.autoloads.key?(autoload_name)
      orig_model.autoloads[autoload_name] = model

      result.fetch(:models) << model
    end

    return result
  end
end
