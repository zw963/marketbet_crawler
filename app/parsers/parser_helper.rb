class ParserHelper
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(headless: true, browser_options: { 'no-sandbox': nil })
  end

  def p2b(percent)
    f = percent.tr('%', '').delete(',').delete('$')

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
    BigDecimal(dollar.gsub(/GBX|\$|£|,/, ''))
  end

  def try_again(page, url)
    puts url
    tries = 0

    begin
      tries += 1
      page.goto(url)
      page.network.wait_for_idle(timeout: 5)
    rescue Ferrum::TimeoutError, Ferrum::PendingConnectionsError
      if tries < 7
        seconds = (1.8**tries).ceil
        puts "[#{Thread.current.object_id}] Retrying #{url} in #{seconds} seconds."
        sleep(seconds)
        retry
      end
    end
  end
end
