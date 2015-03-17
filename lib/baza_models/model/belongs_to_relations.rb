module BazaModels::Model::BelongsToRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def belongs_to(relation_name)
      @belongs_to_relations ||= []
      @belongs_to_relations << {
        relation_name: relation_name
      }

      define_method(relation_name) do
        class_name = StringCases.snake_to_camel(relation_name)
        Object.const_get(class_name).find(@data[:"#{relation_name}_id"])
      end
    end
  end
end
