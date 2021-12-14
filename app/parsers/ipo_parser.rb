require 'bigdecimal/util'

class IpoParser < ParserBase
  def parse
    raise 'symbols must be exists' if symbols.nil?

    log = Log.create(type: 'ipo_parser')
    symbols.uniq.each_slice(1).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(browser) do |browser|
          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          url = "https://www.marketbeat.com/stocks/#{symbol.upcase}/"
          puts url
          page.goto url

          ipo_question = page.css('h3.question').find {|x| x.text.match?(/When did .* IPO/i) }

          if ipo_question.present?
            ipo_info_text = ipo_question.at_xpath('.//../following-sibling::dd').text

            if ipo_info_text.present?
              matched_info = ipo_info_text.match(/raised (.*) in an (?:initial public offering|IPO).*? on (.*)\. The company issued ([\d,]+) shares at (?:a price of )?([$0-9\-.]+) per share/i)

              if matched_info.nil?
                warn "Parse \`#{ipo_info_text}' failed."
              else
                exchange = Exchange.find_or_create(name: symbol.split('/')[0])
                stock = Stock.find_or_create(name: symbol, exchange: exchange)

                captures = matched_info.captures
                ipo_price_range = captures[3].split('-').map {|x| BigDecimal(x.delete('$')) }
                ipo_placement = captures[0]

                ipo_placement_number = case ipo_placement
                                       when /\$([\d.]+) million/
                                         $1.to_d * 1000000
                                       when /\$([\d.]+) billion/
                                         $1.to_d * 1000000000
                                       end

                stock.ipo_placement = ipo_placement
                stock.ipo_placement_number = ipo_placement_number
                stock.ipo_date = captures[1]
                stock.ipo_price = captures[3]
                stock.ipo_average_price = ipo_price_range.sum/ipo_price_range.size
                stock.ipo_amount = captures[2].delete(',')
                stock.save
              end
            end
          end
        ensure
          context.dispose
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)
  end
end
