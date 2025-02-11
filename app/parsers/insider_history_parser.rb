class InsiderHistoryParser < ParserBase
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'insider_parser')
    symbols.uniq.each_slice(2).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(browser) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          url = "https://www.marketbeat.com/stocks/#{symbol.upcase}/insider-trades"
          puts url
          page.goto url

          if (table_ele = page.at_css('.scroll-table.sort-table') rescue nil)
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
            save_to_insider_histories(tables, symbol)
          end

        ensure
          context.dispose
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)
  end

  def save_to_insider_histories(table_ary, symbol)
    exchange = Exchange.find_or_create(name: symbol.split('/')[0])
    stock = Stock.find_or_create(name: symbol, exchange: exchange)

    table_ary[1..].each do |e|
      number_of_holding = e[7] == '' ? nil : e[7].to_i

      name = e[1]

      next if name.blank?

      insider = Insider.find_or_create(name: name.delete('.').squeeze(' '))

      case e[3]
      when 'Sell', 'Issued', 'Proposed Sale'
        xx = -1
      when 'Buy'
        xx = 1
      else
        xx = 1
      end

      # skip AD
      begin
        date = Date.strptime(e[0], '%m/%d/%Y')
      rescue Date::Error
        next
      end

      number_of_shares = e[4].tr(',', '').to_i * xx
      number_of_shares = xx if number_of_shares == 0

      data = {
        date:              date,
        title:             e[2],
        number_of_holding: number_of_holding,
        number_of_shares:  number_of_shares,
        average_price:     d2b(e[5]),
        share_total_price: d2b(e[6]),
        stock:             stock,
        insider:           insider
      }

      DB.transaction do
        if InsiderHistory.find(data).nil?
          InsiderHistory.create(data)
          insider.update(
            last_trade_date:       date,
            last_trade_stock:      stock.name,
            number_of_trade_times: insider.number_of_trade_times.to_i + 1
          )
        end
      end
    end
  end
end
