class BazaModels::Autoloader
  def initialize(args)
    @models = args.fetch(:models)
    @model_class = @models.first.class
    @autoloads = args.fetch(:autoloads)
    @db = args.fetch(:db)
  end

  def autoload
    @autoloads.each do |autoload_name|
      relation = @model_class.relationships.fetch(autoload_name)
      foreign_key = relation.fetch(:foreign_key)

      if relation.fetch(:type) == :has_many
        autoload_has_many(autoload_name, relation)
      elsif relation.fetch(:type) == :belongs_to
        autoload_belongs_to(autoload_name, relation)
      else
        raise "Unknown relation type: #{relation.fetch(:type)}"
      end
    end
  end

private

  def model_ids
    @model_ids ||= @models.map(&:id)
  end

  def autoload_belongs_to(autoload_name, relation)
    sql = "SELECT `#{@model_class.table_name}`.`#{relation.fetch(:foreign_key)}` FROM `#{@model_class.table_name}` WHERE `id` IN (#{model_ids.join(',')})"
    ids = @db.query(sql).to_a.map { |data| data.fetch(relation.fetch(:foreign_key)) }

    model_id_mappings = {}
    @models.each do |model|
      @model_ids << model.id
      model_id_mappings[model.data.fetch(relation.fetch(:foreign_key))] = model.id
    end

    @db.select(relation.fetch(:table_name), id: model_ids) do |model_data|
      model = ::Object.const_get(relation.fetch(:class_name)).new(model_data)

      orig_model_id = model_id_mappings.fetch(model_data.fetch(:id))
      orig_model = @models.select { |array_model| array_model.id == orig_model_id }.first
      orig_model.autoloads[autoload_name] ||= model
    end
  end

  def autoload_has_many(autoload_name, relation)
    @db.select(relation[:table_name], relation.fetch(:foreign_key) => model_ids) do |model_data|
      model = ::Object.const_get(relation[:class_name]).new(model_data)

      orig_model_id = model_data.fetch(relation.fetch(:foreign_key))
      orig_model = @models.select { |array_model| array_model.id == orig_model_id }.first
      orig_model.autoloads[autoload_name] ||= []
      orig_model.autoloads[autoload_name] << model
    end
  end
end
