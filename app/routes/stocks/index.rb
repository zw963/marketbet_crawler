class App
  hash_routes('stocks/index') do
    is true do |r|
      sort_column, sort_direction, stock_name, page, per = r.params.values_at('sort_column', 'sort_direction', 'stock_name', 'page', 'per')

      result = RetrieveStocks.(
        sort_column: sort_column,
        sort_direction: sort_direction,
        page: page,
        per: per,
        stock_name: stock_name
      )

      if result.success?
        @stocks = result.stocks

        r.html do
          view 'stocks/index'
        end

        r.json do
          Stock.as_hash(:name, :name)
        end
      else
        @error_message = result.message
        r.halt
      end
    end
  end
end
