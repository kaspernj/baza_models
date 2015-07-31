module BazaModels::Model::BelongsToRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def belongs_to(relation_name)
      relation = {
        type: :belongs_to,
        relation_name: relation_name,
        table_name: StringCases.pluralize(relation_name),
        foreign_key: :"#{relation_name}_id"
      }

      @belongs_to_relations ||= []
      @belongs_to_relations << relation

      @relationships ||= {}
      @relationships[relation_name] = relation

      define_method(relation_name) do
        class_name = StringCases.snake_to_camel(relation_name)
        Object.const_get(class_name).find(@data.fetch(relation[:foreign_key]))
      end
    end
  end
end
