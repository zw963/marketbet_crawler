class RetrieveStocks < Actor
  input :sort_column, default: 'next_earnings_date', type: String
  input :sort_direction, default: 'asc', type: String
  input :page, default: 1, type: [Integer, String]
  input :per, default: 20, type: [Integer, String]
  input :stock_name, default: nil, type: String

  def call
    sort = case sort_column.to_s
           when *Stock.columns.map(&:name)
             :stocks[sort_column.to_sym]
           when 'exchange_name'
             :exchange[:name]
           end

    if sort_direction.to_s == 'desc'
      sort = sort.desc(nulls: :last)
    else
      sort = sort.asc(nulls: :last)
    end

    stocks = Stock.association_join(:exchange)
      .qualify
      .select_append(:exchange[:name].as(:exchange_name))

    if stock_name.present?
      stocks = stocks.where(:stocks[:name] => stock_name)
    end

    stocks = stocks.order(sort).paginate(page.to_i, per.to_i)

    result.stocks = stocks

    fail!(message: "没有匹配的股票！") if stocks.empty?
  end
end
