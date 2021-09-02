class App
  hash_routes('stocks/index') do
    is true do |r|
      sort_column, sort_direction, name, page, per = r.params.values_at('sort_column', 'sort_direction', 'name', 'page', 'per')

      result = RetrieveStocks.call(sort_column: sort_column, sort_direction: sort_direction, page: page, per: per, name: name)

      if result.success?
        @stocks = result.stocks

        r.html do
          view 'stocks/index'
        end

        r.json do
          @stocks.map(&:to_hash)
        end
      else
        @error_message = result.message
        r.halt
      end
    end
  end
end
