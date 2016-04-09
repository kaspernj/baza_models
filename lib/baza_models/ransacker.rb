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

    @params.each do |key, value|
      if (match = key.to_s.match(/\A(.+?)_eq\Z/))
        filter_eq(match[1], value)
      elsif (match = key.to_s.match(/\A(.+?)_cont\Z/))
        filter_cont(match[1], value)
      elsif key.to_s == "s"
        match = value.to_s.match(/\A([A-z_\d]+)\s+(asc|desc)\Z/)
        raise "Couldn't sort-match: #{value}" unless match
        sort_by(column_name: match[1], sort_mode: match[2])
      end
    end
  end

  def filter_eq(column_name, value)
    BazaModels::Ransacker::RelationshipScanner.new(
      column_name: column_name,
      mode: :eq,
      ransacker: self,
      value: value
    )
  end

  def filter_cont(column_name, value)
    BazaModels::Ransacker::RelationshipScanner.new(
      column_name: column_name,
      mode: :cont,
      ransacker: self,
      value: value
    )
  end

  def sort_by(args)
    BazaModels::Ransacker::RelationshipScanner.new(
      column_name: args.fetch(:column_name),
      mode: :sort,
      ransacker: self,
      value: args.fetch(:sort_mode)
    )
  end
end
