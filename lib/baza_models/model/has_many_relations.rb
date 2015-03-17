module BazaModels::Model::HasManyRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_many(relation_name, *all_args)
      args = all_args.pop

      @has_many_relations ||= []
      @has_many_relations << {
        relation_name: relation_name,
        args: args,
        all_args: all_args
      }

      define_method(relation_name) do
        if args && args[:class_name]
          class_name = args[:class_name]
        else
          class_name = StringCases.snake_to_camel(relation_name.to_s.gsub(/s$/, ""))
        end

        class_instance = Object.const_get(class_name)

        query = class_instance.where("#{StringCases.camel_to_snake(self.class.name)}_id" => id)

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
