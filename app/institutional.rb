class Institutional
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(headless: true, browser_options: { 'no-sandbox': nil })
  end

  def parse
    raise 'symbols must be exists' if symbols.nil?

    symbols.each_slice(1) do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(100)/100.0

          stock_exchange, stock_name = symbol.split('/')
          exchange = Exchange.find_or_create(name: stock_exchange)
          stock = Stock.find_or_create(name: stock_name, exchange: exchange)

          puts "https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership"
          page.go_to("https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership")
          try_again(page)

          if (table_ele = page.at_css('.scroll-table-wrapper-wrapper') rescue nil)
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
            save_to_institutions(tables, symbol)
          end

          sleep rand(100)/100.0
          puts "https://www.marketbeat.com/stocks/#{symbol.upcase}/insider-trades/"
          page.goto("https://www.marketbeat.com/stocks/#{symbol.upcase}/insider-trades/")
          try_again(page)

          if (table_ele = page.at_css('.scroll-table-wrapper-wrapper') rescue nil)
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
            save_to_insiders(tables, stock)
          end

          context.dispose
        end
      end.each(&:join)
    end

    instance.quit
  end

  def save_to_insiders(table_ary, stock)
    # matched_date = [Date.today, Date.today-1].map {|x| x.to_time.strftime('%-m/%d/%Y') }
    # latest_data = table_ary[1..].select {|x| matched_date.include? x[0] }

    table_ary[1..].each do |e|
      number_of_holding = e[7] == "" ? nil : e[7].to_i

      if e[3] == 'Sell'
        xx = -1
      elsif e[3] == 'Buy'
        xx = 1
      elsif e[3] == 'Issued'
        xx = -1
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

  def save_to_institutions(table_ary, symbol)
    matched_date = [Date.today, Date.today-1].map {|x| x.to_time.strftime('%-m/%d/%Y') }
    latest_data = table_ary[1..].select {|x| matched_date.include? x[0] }

    latest_data.each do |e|
      e[3] =~ /\$([\d.,]+)(.?)/
      market_value = BigDecimal($1)
      case
      when $2 == "K"
        value = market_value * 1000
      when $2 == "M"
        value = market_value * 1000000
      when $2 == "B"
        value = market_value * 1000000000
      else
        value = market_value
      end

      number_of_holding = e[2].tr(',', '').to_i
      quarterly_changed_share_percent = p2b(e[5])

      if quarterly_changed_share_percent.nil?
        quarterly_changes = nil
      else
        quarterly_changes = number_of_holding.to_i - ((number_of_holding)/(1+quarterly_changed_share_percent)).to_i
      end

      stock_exchange, stock_name = symbol.split('/')

      Institution.find_or_create(
        {
          name: e[1],
          date: Date.strptime(e[0], '%m/%d/%Y'),
          stock_name: stock_name,
          stock_exchange: stock_exchange,
          number_of_holding: number_of_holding,
          market_value: value,
          market_value_dollar_string: e[3],
          percent_of_shares_for_stock: p2b(e[6]),
          percent_of_shares_for_institution: p2b(e[4]),
          quarterly_changes_percent: quarterly_changed_share_percent,
          quarterly_changes: quarterly_changes,
          holding_cost: sprintf("%.2f", value.to_f/number_of_holding)
        }
      )
    end
  end

  def p2b(percent)
    f = percent.tr('%', '').tr(',', '').tr('$', '')
    if f == "N/A"
      nil
    elsif f == "No Change"
      BigDecimal('0.0')
    else
      BigDecimal(f)/100
    end
  end

  def d2b(dollar)
    BigDecimal(dollar.tr(',', '').tr('$', ''))
  end

    def try_again(page)
    tries = 0
    begin
      tries += 1
      page.network.wait_for_idle(timeout: 30)
    rescue Ferrum::TimeoutError
      puts 'Retrying'
      if (tries < 4)
        sleep(2**tries)
        retry
      end
    end
  end
end
