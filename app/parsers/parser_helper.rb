class MyLogger
  def initialize(logger)
    @logger = logger
  end
  def puts(*args)
    @logger << (args)
  end
end

class ParserHelper
  include Singleton
  attr_accessor :symbols, :instance, :page

  def initialize
    # self.instance = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    self.instance = Ferrum::Browser.new(
      logger: MyLogger.new(Logger.new('chrome_headless.log', 10, 1024000)),
      headless: true,
      pending_connection_errors: false,
      window_size: [1024, 768],
      timeout: 30,
      browser_options: { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false' })
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

  def run
    tries = 0

    begin
      tries += 1
      parse
    rescue Ferrum::TimeoutError, Ferrum::PendingConnectionsError
      if tries < 7
        seconds = (1.8**tries).ceil
        puts "[#{Thread.current.object_id}] Retrying #{url} in #{seconds} seconds because #{$!}"
        sleep(seconds)
        retry
      end
    end
  end
end
