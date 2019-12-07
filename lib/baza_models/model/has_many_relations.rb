module BazaModels::Model::HasManyRelations
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # rubocop:disable Naming/PredicateName
    def has_many(relation_name, *all_args)
      # rubocop:enable Naming/PredicateName

      args = all_args.pop

      relation = {
        type: :has_many,
        relation_name: relation_name,
        table_name: args[:table_name] || relation_name,
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
        relation[:class_name] = StringCases.snake_to_camel(StringCases.singularize(relation_name))
      end

      @has_many_relations ||= []
      @has_many_relations << relation

      @relationships ||= {}
      @relationships[relation_name] = relation

      define_method(relation_name) do
        class_instance = StringCases.constantize(relation.fetch(:class_name))
        query = class_instance.where(relation.fetch(:foreign_key) => id)
        query.previous_model = self
        query.relation = relation

        all_args.each do |arg|
          query = query.instance_exec(&arg) if arg.is_a?(Proc)
        end

        query
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

    true
  end

  def destroy_has_many_relations
    self.class.relationships.each do |relation_name, relation|
      next if relation.fetch(:type) != :has_many || relation[:dependent] != :destroy

      __send__(relation_name).each do |model|
        unless model.destroy
          errors.add(:base, model.errors.full_messages.join(". "))
          return false
        end
      end
    end

    true
  end
end
