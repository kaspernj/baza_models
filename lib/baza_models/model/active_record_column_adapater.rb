class BazaModels::Model::ActiveRecordColumnAdapater
  def initialize(baza_column)
    @baza_column = baza_column
  end

  def name
    @baza_column.name
  end

  def null
    @baza_column.null?
  end

  def sql_type
    result = @baza_column.type.to_s.clone
    result << "(#{@baza_column.maxlength})" if @baza_column.maxlength
    result
  end

  def type
    case @baza_column.type
    when :int
      :integer
    when :tinyint
      :boolean
    when :varchar, :string, :text
      :string
    else
      raise "Unknown type: #{@baza_column.type}"
    end
  end
end
