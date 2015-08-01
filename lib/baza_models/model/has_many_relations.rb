module BazaModels::Model::HasManyRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_many(relation_name, *all_args)
      args = all_args.pop

      relation = {
        type: :has_many,
        relation_name: relation_name,
        table_name: relation_name,
        args: args,
        all_args: all_args,
        foreign_key: :"#{StringCases.camel_to_snake(self.name)}_id"
      }

      if args && args[:class_name]
        relation[:class_name] = args[:class_name]
      else
        relation[:class_name] = StringCases.snake_to_camel(relation_name.to_s.gsub(/s$/, ""))
      end

      @has_many_relations ||= []
      @has_many_relations << relation

      @relationships ||= {}
      @relationships[relation_name] = relation

      define_method(relation_name) do
        class_instance = Object.const_get(relation.fetch(:class_name))
        query = class_instance.where(relation.fetch(:foreign_key) => id)
        query._previous_model = self
        query._relation = relation

        all_args.each do |arg|
          if arg.is_a?(Proc)
            query = query.instance_exec(&arg)
          end
        end

        return query
      end
    end
  end
end
