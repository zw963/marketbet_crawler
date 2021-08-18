class RetrieveStocks
  include Interactor

  def call
    sort_column = context.sort_column || 'id'
    sort_direction = context.sort_direction

    if sort_column.present?
      sort = case sort_column
             when *Stock.columns.map(&:name)
               :stocks[sort_column.to_sym]
             when /^exchange_name$/
               :exchange[:name]
             end
    end

    if sort.present? and sort_direction == 'desc'
      sort = sort.desc
    end

    stocks = Stock.association_join(:exchange)
      .qualify
      .select_append(:exchange[:name].as(:exchange_name))
      .order(sort).all

    if stocks.empty?
      context.fail!(message: "没有最新的结果！")
    else
      context.stocks = stocks
    end
  end
end
