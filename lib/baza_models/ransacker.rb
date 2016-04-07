class BazaModels::Ransacker
  AutoAutoloader.autoload_sub_classes(self, __FILE__)

  attr_accessor :query
  attr_reader :db, :klass

  def initialize(args)
    @klass = args.fetch(:class)
    @db = @klass.db
    @params = args.fetch(:params)
    @query = args.fetch(:query)
  end

  def result
    add_filters_to_query unless @add_filters_to_query_executed
    @query
  end

private

  def add_filters_to_query
    @add_filters_to_query_executed = true
    return unless @params

    table_query = "#{@db.sep_table}#{@db.escape_table(@klass.table_name)}#{@db.sep_table}"

    @params.each do |key, value|
      if (match = key.to_s.match(/\A(.+?)_eq\Z/))
        column_name = match[1]
        column_query = "#{@db.sep_col}#{@klass.db.escape_column(column_name)}#{@db.sep_col}"
        @query = @query.where("#{table_query}.#{column_query} = #{@db.sep_val}#{@klass.db.esc(value)}#{@db.sep_val}")
      elsif (match = key.to_s.match(/\A(.+?)_cont\Z/))
        column_name = match[1]

        BazaModels::Ransacker::RelationshipScanner.new(
          column_name: column_name,
          mode: :cont,
          ransacker: self,
          value: value
        )
      elsif key.to_s == "s"
        match = value.to_s.match(/\A([A-z_\d]+)\s+(asc|desc)\Z/)
        raise "Couldn't sort-match: #{value}" unless match

        column_name = match[1]
        sort_mode = match[2]

        @query = @query.order("#{@db.sep_col}#{@db.escape_column(column_name)}#{@db.sep_col} #{sort_mode}")
      else
        raise "Unknown modifier: #{key}"
      end
    end
  end
end
