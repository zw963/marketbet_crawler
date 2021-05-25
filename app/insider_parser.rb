class InsiderParser
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(headless: true, browser_options: { 'no-sandbox': nil })
  end

  def parse
    raise 'symbols must be exists' if symbols.nil?

    symbols.uniq.each_slice(1) do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(100)/100.0

          stock_exchange, stock_name = symbol.split('/')
          exchange = Exchange.find_or_create(name: stock_exchange)
          stock = Stock.find_or_create(name: stock_name, exchange: exchange)
          sleep rand(100)/100.0
          puts "https://www.marketbeat.com/stocks/#{symbol.upcase}/insider-trades"
          page.goto("https://www.marketbeat.com/stocks/#{symbol.upcase}/insider-trades")
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
    matched_date = [Date.today, Date.today-1].map {|x| x.to_time.strftime('%-m/%d/%Y') }
    latest_data = table_ary[1..].select {|x| matched_date.include? x[0] }

    latest_data = table_ary[1..]

    latest_data.each do |e|
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
    BigDecimal(dollar.tr(',', '').sub(/GBX|\$|£/, ''))
  end

    def try_again(page)
    tries = 0
    begin
      tries += 1
      page.network.wait_for_idle(timeout: 5)
    rescue Ferrum::TimeoutError
      puts 'Retrying'
      if (tries < 4)
        sleep(2**tries)
        retry
      end
    end
  end
end
