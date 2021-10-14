class IpoParser < ParserHelper
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'ipo_parser')
    symbols.uniq.each_slice(1).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          try_again(page, "https://www.marketbeat.com/stocks/#{symbol.upcase}/")

          ipo_question = page.css('h3.question').find {|x| x.text.match?(/When did .* IPO/i) }

          if ipo_question.present?
            ipo_info_text = ipo_question.at_xpath('.//../following-sibling::dd').text

            if ipo_info_text.present?
              matched_info = ipo_info_text.match(/raised (.*) in an initial public offering.*? on (.*)\. The company issued ([\d,]+) shares at (?:a price of )?([$0-9\-.]+) per share/i)

              if matched_info.nil?
                warn "Parse \`#{ipo_info_text}' failed."
              else
                captures = matched_info.captures
                stock_exchange, stock_name = symbol.split('/')
                exchange = Exchange.find_or_create(name: stock_exchange)
                stock = Stock.find_or_create(name: stock_name, exchange: exchange)
                stock.ipo_placement = captures[0]
                stock.ipo_date = captures[1]
                stock.ipo_price = captures[3]
                stock.ipo_amount = captures[2].delete(',')
                stock.save
              end
            end
          end
          context.dispose
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)

  ensure
    instance.quit
  end
end
