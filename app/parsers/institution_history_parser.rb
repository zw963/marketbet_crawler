class InstitutionHistoryParser < ParserBase
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'institution_parser')
    symbols.uniq.each_slice(2).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(browser) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          url = "https://www.marketbeat.com/stocks/#{symbol.upcase}/institutional-ownership"
          puts url
          page.goto url

          if (table_ele = page.at_css('.scroll-table-wrapper-wrapper') rescue nil)
            tables = table_ele.inner_text.split("\n").reject(&:empty?).map {|x| x.split("\t") }

            exchange = Exchange.find_or_create(name: symbol.split('/')[0])
            stock = Stock.find_or_create(name: symbol, exchange: exchange)

            latest_data = tables[1..]

            div = page.at_css('div#cphPrimaryContent_tabInstitutionalOwnership')
            percent_ele = div&.at_xpath('.//strong[contains(text(), "Institutional Ownership Percentage:")]/..')

            unless percent_ele.nil?
              percent = percent_ele.inner_text[/([\d.]+)%/, 1]
              stock.update(percent_of_institutions: BigDecimal(percent) / 100)
            end

            save_to_institution_history(latest_data, stock)
          end

        ensure
          context.dispose
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)
  end

  def save_to_institution_history(latest_data, stock)
    latest_data.each do |e|
      # Fix AD
      begin
        number_of_holding = e[2].tr(',', '').to_i
      rescue NoMethodError
        next
      end

      e[3] =~ /\$([\d.,]+)(.?)/
      market_value = BigDecimal($1) rescue nil

      next if market_value.nil?

      case $2
      when 'K'
        value = market_value * 1000
      when 'M'
        value = market_value * 1000000
      when 'B'
        value = market_value * 1000000000
      else
        value = market_value
      end

      quarterly_changed_share_percent = p2b(e[5])

      if quarterly_changed_share_percent.nil?
        quarterly_changes = nil
      else
        percent = (number_of_holding / (1 + quarterly_changed_share_percent))
        if percent.nan?
          quarterly_changes = nil
        else
          quarterly_changes = number_of_holding - percent.to_i
        end
      end

      name = e[1]

      institution = Institution.find_or_create(name: name)

      InstitutionHistory.find_or_create(
        {
          institution_id:                    institution.id,
          date:                              Date.strptime(e[0], '%m/%d/%Y'),
          stock:                             stock,
          number_of_holding:                 number_of_holding,
          market_value:                      value,
          market_value_dollar_string:        e[3],
          percent_of_shares_for_stock:       p2b(e[6]),
          percent_of_shares_for_institution: p2b(e[4]),
          quarterly_changes_percent:         quarterly_changed_share_percent,
          quarterly_changes:                 quarterly_changes,
          holding_cost:                      format('%.2f', value.to_f / number_of_holding)
        }
      )
    end
  end
end
