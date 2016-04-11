module BazaModels::Query::Pagination
  def current_page
    if @page
      @page
    else
      raise "Page has not been set"
    end
  end

  def out_of_bounds?
    current_page > total_pages
  end

  def page(some_page = :non_given)
    if some_page == :non_given
      @page ||= 1
    else
      some_page ||= 1
      some_page = some_page.to_i
      offset = (some_page - 1) * per

      clone(page: some_page, offset: offset, limit: per)
    end
  end

  def paginated?
    @page != nil
  end

  def per(value = :non_given)
    if value == :non_given
      @per ||= 30
    else
      value = value.to_i
      offset = (page - 1) * value
      clone(limit: value, offset: offset, per: value)
    end
  end

  alias per_page per

  def total_entries
    @model.count
  end

  def total_pages
    pages_count = (count.to_f / per.to_f)

    pages_count = 1 if pages_count.nan? || pages_count == Float::INFINITY
    pages_count = pages_count.ceil
    pages_count = 1 if pages_count == 0
    pages_count
  end
end
