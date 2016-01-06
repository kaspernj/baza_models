module BazaModels::Model::Queries
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find(id)
      row = db.select(table_name, {id: id}, limit: 1).fetch
      raise BazaModels::Errors::RecordNotFound, "Record not found by ID: #{id}" unless row
      new(row, init: true)
    end

    def find_by(where_hash)
      row = db.select(table_name, where_hash, limit: 1).fetch
      return new(row, init: true) if row
      false
    end

    def find_by!(where_hash)
      model = find_by(where_hash)
      return model if model
      raise BazaModels::Errors::RecordNotFound, "Record not found by arguments: #{where_hash}" unless model
    end

    def find_or_initialize_by(data)
      model = find_by(data)
      return model if model
      new(data)
    end

    def find_or_create_by(data)
      model = find_or_initialize_by(data)
      model.save if model.new_record?
      yield model if block_given?
      model
    end

    def find_or_create_by!(data)
      model = find_or_initialize_by(data)
      model.save! if model.new_record?
      yield model if block_given?
      model
    end
  end
end
