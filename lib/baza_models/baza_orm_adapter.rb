require "orm_adapter"

class BazaModels::BazaOrmAdapter < OrmAdapter::Base
  def initialize(args)
    @klass = args.fetch(:class)
  end

  def column_names
    klass.column_names
  end

  def get!(id)
    klass.find(wrap_key(id))
  end

  def get(id)
    klass.where(id: wrap_key(id)).first
  end

  def find_first(options)
    klass.find_first(options)
  end

  def find_all(options = {})
    klass.where(options)
  end

  def create!(attributes = {})
    klass.create!(attributes)
  end

  def destroy(object)
    if valid_object?(object)
      object.destroy
    else
      false
    end
  end
end
