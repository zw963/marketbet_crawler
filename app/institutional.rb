class Institutional
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: false, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(headless: true, browser_options: { 'no-sandbox': nil })
  end

  def parse
    raise 'symbols must be exists' if symbols.nil?

    symbols.map do |symbol|
      Thread.new(instance) do |browser|
        context = browser.contexts.create
        page = context.create_page
        sleep rand(100)/100.0
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
          # puts Terminal::Table.new :rows => tables
          print_table(tables, symbol)
        end

        context.dispose
      end
    end.each(&:join)

    instance.quit
  end

  def save_to_institutions(text, symbol)
    table_ary = text.split("\n").reject(&:empty?).map {|x| x.split("\t") }
    matched_date = [Date.today, Date.today-1].map {|x| x.to_time.strftime('%-m/%d/%Y') }
    latest_data = table_ary[1..-1].select {|x| matched_date.include? x[0] }

    data = latest_data.map do |e|
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
      quarterly_changed_share_percent = e[5].tr('%', '').to_f/100
      quarterly_changes = number_of_holding.to_i - ((number_of_holding)/(1+quarterly_changed_share_percent)).to_i

      Institution.find_or_create(
        name: e[1],
        date: Date.strptime(e[0], '%m/%d/%Y'),
        stock_name: symbol,
        number_of_holding: number_of_holding,
        market_value: value,
        market_value_dollar_string: e[3],
        percent_of_shares_for_stock: e[6].tr('%', '').to_f/100,
        percent_of_shares_for_institution: e[4].tr('%', '').to_f/100,
        quarterly_changes_percent: quarterly_changed_share_percent,
        quarterly_changes: quarterly_changes,
        holding_cost: sprintf("%.2f", value.to_f/number_of_holding)
      )
    end
  end

  def print_table(symbol)
    heading = [
      "股票",
      "日期",
      "机构名称",
      "持有数量",
      "市场价值",
      "占股票百分比",
      "占机构百分比",
      "机构季度变动百分比",
      "机构季度变动数量",
      "机构平均成本"
    ]

    matched_date = [Date.today, Date.today-1]
    result = Institution.where(stock_name: symbol, date: matched_date).all

    data = result.map do |x|
      x1 = x.market_value .divmod(10000)
      value = x1[0].to_f + x1[1]/10000.to_f

      if x.quarterly_changes_percent == 0.0
        value1 = 'NA'
        value2 = 'NA'
      else
        value1 = (x.quarterly_changes_percent*100).to_f.to_s + "%"
        value2 = x.quarterly_changes
      end

      [
        symbol,
        x.date.to_s,
        x.name,
        x.number_of_holding,
        "#{value}万(#{x.market_value_dollar_string})",
        (x.percent_of_shares_for_stock*100).to_f.to_s + "%",
        (x.percent_of_shares_for_institution*100).to_f.to_s + "%",
        value1,
        value2,
        x.holding_cost.to_f
      ]
    end

    table = Terminal::Table.new do |t|
      t.style = { :border => :unicode_round }
      t.headings = heading
      data.each {|e| t.add_row(e) }
      t.style = {:all_separators => true}
    end

    puts table
  end
end
