class InsiderHistoryParser < ParserBase
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'insider_parser')
    client = FinnhubRuby::DefaultApi.new

    symbols.uniq.each_slice(2).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        stock_symbol = symbol.split("/").last

        Thread.new(client) do |client|
          # 处理 "nasdaq/amd" 或 "amd" 两种形式
          result = client.stock_insider_transactions(stock_symbol)["data"]
          exchange = Exchange.find_or_create(name: symbol.split("/").first)
          stock = Stock.find_or_create(name: symbol, exchange: exchange)

          result.each do |record|
            insider = Insider.find_or_create(name: record["name"])
            share_change_count = record["change"] # 整数，正数或负数
            average_price = BigDecimal(record["transactionPrice"].to_s)
            date = Date.strptime(record["transactionDate"], '%Y-%m-%d')

            data = {
              date: date,
              sec_id: record["id"],
              number_of_holding: record["share"], # 整数，可能为 0
              number_of_shares: share_change_count,
              average_price:     average_price,
              share_total_price: share_change_count * average_price,
              stock: stock,
              insider: insider
            }

            if InsiderHistory.find(data).nil?
              DB.transaction do
                InsiderHistory.create(data.merge("title": "Insider"))
                insider.update(
                  last_trade_date:       date,
                  last_trade_stock:      stock.name,
                  number_of_trade_times: insider.number_of_trade_times.to_i + 1
                )
              end
            end
          end
        end.join
      end

      log.update(finished_at: Time.now)
    end
  end
end
