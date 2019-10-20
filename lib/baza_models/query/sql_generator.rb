class BazaModels::Query::SqlGenerator
  def initialize(args)
    @query = args.fetch(:query)

    instance_variables = [:db, :selects, :joins, :wheres, :groups, :orders, :per, :limit, :offset, :model, :table_name, :reverse_order]
    instance_variables.each do |instance_variable|
      value = @query.instance_variable_get(:"@#{instance_variable}")
      instance_variable_set(:"@#{instance_variable}", value)
    end
  end

  def to_sql
    sql = "SELECT "

    if @selects.empty?
      sql << "#{@db.sep_table}#{@model.table_name}#{@db.sep_table}.*"
    else
      sql << @selects.join(", ")
    end

    sql << " FROM #{@db.sep_table}#{@model.table_name}#{@db.sep_table}"

    unless @joins.empty?
      @joins.each do |join|
        sql << " #{join}"
      end
    end

    unless @wheres.empty?
      sql << " WHERE "

      first = true
      @wheres.each do |where|
        if first == true
          first = false
        else
          sql << " AND "
        end

        sql << where
      end
    end

    unless @groups.empty?
      sql << " GROUP BY "

      first = true
      @groups.each do |group|
        if first
          first = false
        else
          sql << ", "
        end

        sql << group
      end
    end

    unless @orders.empty?
      sql << " ORDER BY "

      first = true
      @orders.each do |order|
        if first
          first = false
        else
          sql << ", "
        end

        if @reverse_order
          if /\s+desc/i.match?(order)
            order = order.gsub(/\s+desc/i, " ASC")
          elsif /\s+asc/i.match?(order)
            order = order.gsub(/\s+asc/i, " DESC")
          else
            order = "#{order} DESC"
          end
        end

        sql << order
      end
    end

    if @limit && @offset
      sql << " LIMIT #{@offset.to_i}, #{@limit.to_i}"
    elsif @limit
      sql << " LIMIT #{@limit.to_i}"
    end

    sql.strip
  end
end
