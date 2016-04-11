class BazaModels::Ransacker
  AutoAutoloader.autoload_sub_classes(self, __FILE__)

  attr_accessor :query
  attr_reader :db, :klass

  def initialize(args)
    @klass = args.fetch(:class)
    @db = @klass.db
    @params = args.fetch(:params)
    @_registered_params = @params # Support for SimpleFormRansack
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

    ransackable_scopes = @klass.ransackable_scopes.map(&:to_s) if @klass.respond_to?(:ransackable_scopes)

    @params.each do |key, value|
      if (match = key.to_s.match(/\A(.+?)_(cont|eq|lt|lteq|gt|gteq)\Z/))
        filter(match[1], value, match[2])
      elsif key.to_s == "s"
        match = value.to_s.match(/\A([A-z_\d]+)\s+(asc|desc)\Z/)
        raise "Couldn't sort-match: #{value}" unless match
        sort_by(column_name: match[1], sort_mode: match[2])
      elsif ransackable_scopes && ransackable_scopes.include?(key.to_s)
        @query = @query.__send__(key, value)
      end
    end
  end

  def filter(column_name, value, mode)
    BazaModels::Ransacker::RelationshipScanner.new(
      column_name: column_name,
      mode: mode.to_sym,
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
