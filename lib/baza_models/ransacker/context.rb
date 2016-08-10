class BazaModels::Ransacker::Context
  attr_reader :search_key

  def initialize(args)
    @search_key = args.fetch(:search_key)
  end
end
