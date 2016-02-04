class BazaModels::Query::Not
  def initialize(args)
    @query = args.fetch(:query)
    @model = @query.instance_variable_get(:@model)
    @db = @query.instance_variable_get(:@db)
    @wheres = @query.instance_variable_get(:@wheres)
  end

  def not(args)
    args.each do |key, value|
      if value.is_a?(Hash)
        value.each do |hash_key, hash_value|
          if hash_value.is_a?(Array)
            values = hash_value.map { |hash_value_i| "'#{@db.esc(hash_value_i)}'" }.join(",")

            @wheres << "`#{key}`.`#{hash_key}` NOT IN (#{values})"
          else
            @wheres << "`#{key}`.`#{hash_key}` != '#{@db.esc(hash_value)}'"
          end
        end
      elsif value.is_a?(Array)
        values = value.map { |value_i| "'#{@db.esc(value_i)}'" }.join(",")

        @wheres << "`#{@model.table_name}`.`#{key}` NOT IN (#{values})"
      else
        @wheres << "`#{@model.table_name}`.`#{key}` != '#{@db.esc(value)}'"
      end
    end

    @query
  end
end
