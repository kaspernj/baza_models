class BazaModels::CanCanAdapter < CanCan::ModelAdapters::AbstractAdapter
  def self.for_class?(klass)
    klass.is_a?(BazaModels::Query)
  end

  def database_records
    @model_class.all
  end
end
