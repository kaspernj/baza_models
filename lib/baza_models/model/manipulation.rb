module BazaModels::Model::Manipulation
  def self.included(base)
    base.extend(ClassMethods)
  end

  def save
    if valid?
      new_record = new_record?
      fire_callbacks(:before_save)
      self.updated_at = Time.now if has_attribute?(:updated_at)

      if new_record
        status = create
      else
        db.update(table_name, @changes, id: id)
        status = true
      end

      return false unless status

      @changes = {}
      @new_record = false
      reload

      fire_callbacks(:after_save)
      fire_callbacks(:after_create) if new_record

      return true
    else
      return false
    end
  end

  def create
    unless new_record?
      errors.add(:base, "cannot create unless new record")
      return false
    end

    fire_callbacks(:before_create)
    self.created_at = Time.now if has_attribute?(:created_at) && !created_at?

    @data[:id] = db.insert(table_name, @data.merge(@changes), return_id: true)

    if @autoloads
      @autoloads.each do |relation_name, collection|
        relation = self.class.relationships.fetch(relation_name)

        collection.each do |model|
          model.assign_attributes(relation.fetch(:foreign_key) => id)
          model.create! if model.new_record?
        end
      end
    end

    return true
  end

  def create!
    if create
      return true
    else
      raise BazaModels::Errors::InvalidRecord, errors.full_messages.join(". ")
    end
  end

  def save!
    if save
      return true
    else
      raise BazaModels::Errors::InvalidRecord, errors.full_messages.join(". ")
    end
  end

  def update_attributes(attributes)
    assign_attributes(attributes)
    return save
  end

  def update_attributes!(attributes)
    unless update_attributes(attributes)
      raise BazaModels::Errors::InvalidRecord, @errors.full_messages.join(". ")
    end
  end

  def assign_attributes(attributes)
    @changes.merge!(real_attributes(attributes))
  end

  def destroy
    if new_record?
      errors.add(:base, "cannot destroy new record")
      return false
    else
      fire_callbacks(:before_destroy)

      return false unless restrict_has_one_relations
      return false unless restrict_has_many_relations
      return false unless destroy_has_one_relations
      return false unless destroy_has_many_relations

      db.delete(table_name, id: id)
      fire_callbacks(:after_destroy)
      return true
    end
  end

  def destroy!
    raise BazaModels::Errors::InvalidRecord, @errors.full_messages.join(". ") unless destroy
  end

  module ClassMethods
    def create(data = {})
      model = new(data)
      model.save

      return model
    end

    def create!(data = {})
      model = new(data)
      model.save!

      return model
    end
  end
end
