class InstitutionParser
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    self.instance = Ferrum::Browser.new(headless: true, browser_options: { 'no-sandbox': nil })
  end

  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'institution_parser')
    symbols.uniq.each_slice(2).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          try_again(page, "https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership")

          if (table_ele = page.at_css('.scroll-table-wrapper-wrapper') rescue nil)
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }

            stock_exchange, stock_name = symbol.split('/')
            exchange = Exchange.find_or_create(name: stock_exchange)
            stock = Stock.find(name: stock_name, exchange: exchange)

            stock = Stock.find_or_create(name: stock_name, exchange: exchange)
            latest_data = tables[1..]

            div = page.at_css('div#cphPrimaryContent_tabInstitutionalOwnership')
            percent_ele = div&.at_xpath('.//strong[contains(text(), "Institutional Ownership Percentage:")]/..')

            unless percent_ele.nil?
              percent = percent_ele.inner_text[/([\d.]+)%/, 1]
              stock.update(percent_of_institutions: BigDecimal(percent)/100)
            end

            save_to_institutions(latest_data, stock)
          end

          context.dispose
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)

    instance.quit
  end

  def save_to_institutions(latest_data, stock)
    latest_data.each do |e|
      e[3] =~ /\$([\d.,]+)(.?)/
      market_value = BigDecimal($1)
      case $2
      when "K"
        value = market_value * 1000
      when "M"
        value = market_value * 1000000
      when "B"
        value = market_value * 1000000000
      else
        value = market_value
      end

      number_of_holding = e[2].tr(',', '').to_i
      quarterly_changed_share_percent = p2b(e[5])

      if quarterly_changed_share_percent.nil?
        quarterly_changes = nil
      else
        quarterly_changes = number_of_holding - (number_of_holding/(1+quarterly_changed_share_percent)).to_i
      end

      name = e[1]

      firm = Firm.find_or_create(name: name)

      Institution.find_or_create(
        {
          name: name,
          firm_id: firm.id,
          date: Date.strptime(e[0], '%m/%d/%Y'),
          stock: stock,
          number_of_holding: number_of_holding,
          market_value: value,
          market_value_dollar_string: e[3],
          percent_of_shares_for_stock: p2b(e[6]),
          percent_of_shares_for_institution: p2b(e[4]),
          quarterly_changes_percent: quarterly_changed_share_percent,
          quarterly_changes: quarterly_changes,
          holding_cost: format("%.2f", value.to_f/number_of_holding)
        }
      )
    end
  end

  def p2b(percent)
    f = percent.tr('%', '').tr(',', '').tr('$', '')
    case f
    when "N/A"
      nil
    when "No Change"
      BigDecimal('0.0')
    else
      BigDecimal(f)/100
    end
  end

  def d2b(dollar)
    BigDecimal(dollar.tr(',', '').tr('$', ''))
  end

  def try_again(page, url)
    tries = 0
    puts url
    begin
      page.goto(url)
      tries += 1
      page.network.wait_for_idle(timeout: 5)
    rescue Ferrum::TimeoutError, Ferrum::PendingConnectionsError
      if tries < 7
        seconds = (1.8**tries).floor
        puts "[#{Thread.current.object_id}] Retrying in #{seconds} seconds."
        sleep(seconds)
        retry
      end
    end
  end
end
