class InsiderHistoryParser < ParserBase
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'insider_parser')
    client = FinnhubRuby::DefaultApi.new

    symbols.uniq.each_slice(2).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        # 处理 "nasdaq/amd" 或 "amd" 两种形式
        stock_symbol = symbol.split("/").last
        from = Date.today - from_date_size
        to = Date.today

        exchange = Exchange.find_or_create(name: symbol.split("/").first)
        stock = Stock.find_or_create(name: symbol, exchange: exchange)

        Thread.new(client) do |client|
          # 这个 API 调用接受支持一个空字符串作为参数，返回最新的。
          result = client.stock_insider_transactions(stock_symbol, from: from.to_s, to: to.to_s)["data"]

          next 0 if result.empty?

          warn "New data from #{from} to #{to} for #{symbol}"

          result.each do |record|
            insider = Insider.find_or_create(name: record["name"])
            share_change_count = record["change"] # 整数，正数或负数
            average_price = BigDecimal(record["transactionPrice"].to_s)
            date = Date.strptime(record["transactionDate"], '%Y-%m-%d')

            data1 = {
              date: date,
              sec_id: record["id"],
              number_of_holding: record["share"], # 整数，可能为 0
              number_of_shares: share_change_count,
              average_price:     average_price,
              share_total_price: share_change_count * average_price,
              stock: stock,
              insider: insider
            }

            if InsiderHistory.find(data1).nil?
              DB.transaction do
                InsiderHistory.create(data1.merge("title": "Insider"))
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
