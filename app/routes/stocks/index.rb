class App
  hash_routes('stocks/index') do
    is true do |r|
      result = RetrieveStocks.result(r.params)

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
