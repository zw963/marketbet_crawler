class InsiderParser < ParserHelper
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'insider_parser')
    symbols.uniq.each_slice(2).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          try_again(page, "https://www.marketbeat.com/stocks/#{symbol.upcase}/insider-trades")

          if (table_ele = page.at_css('.scroll-table-wrapper-wrapper') rescue nil)
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
            save_to_insiders(tables, symbol)
          end

          context.dispose
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)

  ensure
    instance.quit
  end

  def save_to_insiders(table_ary, symbol)
    stock_exchange, stock_name = symbol.split('/')
    exchange = Exchange.find_or_create(name: stock_exchange)
    stock = Stock.find_or_create(name: stock_name, exchange: exchange)

    table_ary[1..].each do |e|
      number_of_holding = e[7] == "" ? nil : e[7].to_i

      case e[3]
      when 'Sell', 'Issued'
        xx = -1
      when 'Buy'
        xx = 1
      end

      Insider.find_or_create(
        {
          date: Date.strptime(e[0], '%m/%d/%Y'),
          name:  e[1],
          title: e[2],
          number_of_holding: number_of_holding,
          number_of_shares: e[4].tr(',', '').to_i*xx,
          average_price: d2b(e[5]),
          share_total_price: d2b(e[6]),
          stock: stock
        }
      )
    end
  end
end
