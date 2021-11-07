class RetrieveStocks
  include Interactor

  def call
    sort_column = context.sort_column || 'next_earnings_date'
    sort_direction = context.sort_direction
    page = context.page || 1
    per = context.per || 10
    name = context.name

    if sort_column.present?
      sort = case sort_column.to_s
             when *Stock.columns.map(&:name)
               :stocks[sort_column.to_sym]
             when 'exchange_name'
               :exchange[:name]
             end
    end

    if sort.present?
      if sort_direction.to_s == 'desc'
        sort = sort.desc(nulls: :last)
      else
        sort = sort.asc(nulls: :last)
      end
    end

    stocks = Stock.association_join(:exchange)
      .qualify
      .select_append(:exchange[:name].as(:exchange_name))

    if name.present?
      stocks = stocks.where(:stocks[:name] => name)
    end

    stocks = stocks.order(sort).paginate(page.to_i, per.to_i)

    if stocks.empty?
      context.fail!(message: "没有最新的结果！")
    else
      context.stocks = stocks
    end
  end
end
