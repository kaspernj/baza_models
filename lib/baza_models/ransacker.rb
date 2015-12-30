class BazaModels::Ransacker
  def initialize(args)
    @klass = args.fetch(:class)
    @params = args.fetch(:params)
    @query = @klass
  end

  def result
    add_filters_to_query
    @query
  end

private

  def add_filters_to_query
    return unless @params

    @params.each do |key, value|
      if (match = key.to_s.match(/\A(.+?)_eq\Z/))
        column_name = match[1]
        @query = @query.where("`#{@klass.table_name}`.`#{@klass.db.escape_column(column_name)}` = '#{@klass.db.esc(value)}'")
      elsif (match = key.to_s.match(/\A(.+?)_cont\Z/))
        column_name = match[1]
        @query = @query.where("`#{@klass.table_name}`.`#{@klass.db.escape_column(column_name)}` LIKE '%#{@klass.db.esc(value)}%'")
      else
        raise "Unknown modifier: #{key}"
      end
    end
  end
end
