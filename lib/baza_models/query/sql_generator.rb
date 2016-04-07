class BazaModels::Query::SqlGenerator
  def initialize(args)
    @query = args.fetch(:query)

    instance_variables = [
      :selects, :joins, :wheres, :groups, :orders, :limit, :offset,
      :model, :table_name, :reverse_order
    ]
    instance_variables.each do |instance_variable|
      value = @query.instance_variable_get(:"@#{instance_variable}")
      instance_variable_set(:"@#{instance_variable}", value)
    end
  end

  def to_sql
    sql = "SELECT "

    if @selects.empty?
      sql << "`#{@model.table_name}`.*"
    else
      sql << @selects.join(", ")
    end

    sql << " FROM `#{@model.table_name}`"

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
          if order =~ /\s+desc/i
            order = order.gsub(/\s+desc/i, " ASC")
          elsif order =~ /\s+asc/i
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
