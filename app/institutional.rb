class Institutional
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(headless: true, browser_options: { 'no-sandbox': nil })
  end

  def parse
    raise 'symbols must be exists' if symbols.nil?

    symbols.each_slice(3) do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(100)/100.0
          puts "https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership"
          page.go_to("https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership")

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

          # if (ele = browser.at_css('#optinform-modal'))
          #   ele.evaluate("closeIframeModal();return false;")
          # end

          if (table_ele = page.at_css('.scroll-table-wrapper-wrapper'))
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
            save_to_institutions(tables, symbol)
          end

          context.dispose
        end
      end.each(&:join)
    end

    instance.quit
  end

  def save_to_institutions(table_ary, symbol)
    matched_date = [Date.today, Date.today-1].map {|x| x.to_time.strftime('%-m/%d/%Y') }
    latest_data = table_ary[1..-1].select {|x| matched_date.include? x[0] }

    data = table_ary.map do |e|
      e[3] =~ /\$([\d.,]+)(.?)/
      case
      when $2 == "K"
        value = $1.to_f * 1000
      when $2 == "M"
        value = $1.to_f * 1000000
      when $2 == "B"
        value = $1.to_f * 1000000000
      else
        value = $1.to_f
      end

      number_of_holding = e[2].tr(',', '').to_i
      quarterly_changed_share_percent = p2b(e[5])
      quarterly_changes = number_of_holding.to_i - ((number_of_holding)/(1+quarterly_changed_share_percent)).to_i

      stock_exchange, stock_name = symbol.split('/')

      Institution.find_or_create(
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
      )
    end
  end

  def p2b(percent)
    f = percent.tr('%', '')
    if f == "NA"
      BigDecimal('0.0')
    else
      BigDecimal(f)/100
    end
  end
end
