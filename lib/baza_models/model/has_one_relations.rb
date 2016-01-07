module BazaModels::Model::HasOneRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # rubocop:disable Style/PredicateName
    def has_one(relation_name, *all_args)
      # rubocop:enable Style/PredicateName

      args = all_args.pop

      relation = {
        type: :has_one,
        relation_name: relation_name,
        table_name: args[:table_name] || StringCases.pluralize(relation_name),
        args: args,
        all_args: all_args
      }

      if args[:foreign_key]
        relation[:foreign_key] = args.fetch(:foreign_key)
      else
        relation[:foreign_key] = :"#{StringCases.camel_to_snake(name)}_id"
      end

      relation[:dependent] = args.fetch(:dependent) if args[:dependent]

      if args && args[:class_name]
        relation[:class_name] = args.fetch(:class_name)
      else
        relation[:class_name] = StringCases.snake_to_camel(relation_name)
      end

      @has_one_relations ||= []
      @has_one_relations << relation

      relationships[relation_name] = relation

      define_method(relation_name) do
        if (model = autoloads[relation_name])
          model
        else
          if relation[:args][:through]
            __send__(relation[:args][:through]).__send__(relation_name)
          else
            class_instance = StringCases.constantize(relation.fetch(:class_name))

            query = class_instance.where(relation.fetch(:foreign_key) => id)
            query._previous_model = self
            query._relation = relation

            all_args.each do |arg|
              query = query.instance_exec(&arg) if arg.is_a?(Proc)
            end

            query.first
          end
        end
      end
    end
  end

private

  def restrict_has_one_relations
    self.class.relationships.each do |relation_name, relation|
      next if relation.fetch(:type) != :has_one || relation[:dependent] != :restrict_with_error

      if __send__(relation_name)
        errors.add(:base, "can't be destroyed because it contains #{relation_name}")
        return false
      end
    end

    true
  end

  def destroy_has_one_relations
    self.class.relationships.each do |relation_name, relation|
      next if relation.fetch(:type) != :has_one || relation[:dependent] != :destroy

      model = __send__(relation_name)

      if model && !model.destroy
        errors.add(:base, model.errors.full_messages.join(". "))
        return false
      end
    end

    true
  end
end
