require 'bigdecimal/util'
require 'date'

class EarningsParser < ParserBase
  def parse
    raise 'symbols must be exists' if symbols.nil?

    stock_symbol_mapping = YAML.load_file(APP_ROOT.join('config/mapping.yml')).dig('stock_symbol_mapping')

    log = Log.create(type: 'earnings_parser')

    symbols.uniq.each_slice(1).to_a.shuffle.each do |symbol_group|
      symbol_group.map do |symbol|
        Thread.new(instance) do |browser|
          stock_exchange, stock_name = symbol.split('/')
          exchange = Exchange.find_or_create(name: stock_exchange)
          stock = Stock.find_or_create(name: stock_name, exchange: exchange)
          next if stock.next_earnings_date.present? && stock.next_earnings_date >= Date.today

          context = browser.contexts.create
          page = context.create_page
          sleep rand(3)

          url = "https://cn.investing.com/equities/#{stock_symbol_mapping.dig(symbol, 'investing')}-earnings/"
          puts "#{symbol}, goto #{url}"
          page.goto url

          upcoming_earnings_dates = page
            .css("tr[name='instrumentEarningsHistory'] td.bold.left")
            .map { Date.strptime(_1.text, "%Y年%m月%d日") }
            .select! {_1 > Date.today}

          if upcoming_earnings_dates.present?
            stock.next_earnings_date = upcoming_earnings_dates.min
            stock.save
          end
        ensure
          context.dispose unless context.nil?
        end
      end.each(&:join)
    end

    log.update(finished_at: Time.now)

  ensure
    instance.quit
  end
end
