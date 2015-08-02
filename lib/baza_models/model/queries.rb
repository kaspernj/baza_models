module BazaModels::Model::Queries
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find(id)
      row = db.select(table_name, {id: id}, limit: 1).fetch
      raise BazaModels::Errors::RecordNotFound, "Record not found by ID: #{id}" unless row
      return new(row)
    end

    def find_by(where_hash)
      row = db.select(table_name, where_hash, limit: 1).fetch
      raise BazaModels::Errors::RecordNotFound, "Record not found by ID: #{id}" unless row
      return new(row)
    end
  end
end
