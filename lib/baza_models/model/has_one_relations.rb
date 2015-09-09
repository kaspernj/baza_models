module BazaModels::Model::HasOneRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_one(relation_name, *all_args)
      args = all_args.pop

      relation = {
        type: :has_one,
        relation_name: relation_name,
        table_name: relation_name,
        args: args,
        all_args: all_args
      }

      if args[:foreign_key]
        relation[:foreign_key] = args.fetch(:foreign_key)
      else
        relation[:foreign_key] = :"#{StringCases.camel_to_snake(self.name)}_id"
      end

      relation[:dependent] = args.fetch(:dependent) if args[:dependent]

      if args && args[:class_name]
        relation[:class_name] = args.fetch(:class_name)
      else
        relation[:class_name] = StringCases.snake_to_camel(relation_name)
      end

      @has_one_relations ||= []
      @has_one_relations << relation

      @relationships ||= {}
      @relationships[relation_name] = relation

      define_method(relation_name) do
        if model = autoloads[relation_name]
          model
        else
          if relation[:args][:through]
            __send__(relation[:args][:through]).__send__(relation_name)
          else
            if relation[:class_name]
              class_name = relation.fetch(:class_name)
            else
              class_name = StringCases.snake_to_camel(relation_name)
            end

            class_instance = Object.const_get(relation.fetch(:class_name))

            query = class_instance.where(relation.fetch(:foreign_key) => id)
            query._previous_model = self
            query._relation = relation

            all_args.each do |arg|
              if arg.is_a?(Proc)
                query = query.instance_exec(&arg)
              end
            end

            query.first
          end
        end
      end
    end
  end

private

  def restrict_has_many_relations
    self.class.relationships.each do |relation_name, relation|
      next if relation.fetch(:type) != :has_many || relation[:dependent] != :restrict_with_error

      if __send__(relation_name).any?
        errors.add(:base, "can't be destroyed because it contains #{relation_name}")
        return false
      end
    end

    return true
  end

  def destroy_has_many_relations
    self.class.relationships.each do |relation_name, relation|
      next if relation.fetch(:type) != :has_many || relation[:dependent] != :destroy

      __send__(relation_name).each do |model|
        unless model.destroy
          errors.add(:base, model.errors.full_messages.join('. '))
          return false
        end
      end
    end

    return true
  end
end
