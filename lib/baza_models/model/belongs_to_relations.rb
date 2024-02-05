module BazaModels::Model::BelongsToRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def belongs_to(relation_name, args = {})
      relation = {
        type: :belongs_to,
        relation_name: relation_name,
        table_name: args[:table_name] || StringCases.pluralize(relation_name),
        foreign_key: :"#{relation_name}_id"
      }

      if args[:class_name]
        relation[:class_name] = args.fetch(:class_name)
      else
        relation[:class_name] = StringCases.snake_to_camel(relation_name)
      end

      @belongs_to_relations ||= []
      @belongs_to_relations << relation

      @relationships ||= {}
      @relationships[relation_name] = relation

      define_method(relation_name) do
        if (model = @changes[relation_name]) || (model = autoloads[relation_name])
          model
        else
          if relation[:class_name]
            class_name = relation.fetch(:class_name)
          else
            class_name = StringCases.snake_to_camel(relation_name)
          end

          foreign_id = @data.fetch(relation.fetch(:foreign_key))
          StringCases.constantize(class_name).find(foreign_id) if foreign_id
        end
      end

      define_method(:"#{relation_name}=") do |new_model|
        @changes[relation.fetch(:foreign_key)] = new_model.id
        autoloads.delete(relation_name)
      end
    end
  end
end
