require 'singleton'

class ChromeHeadlessLogger
  def initialize(logger)
    @logger = logger
  end

  def puts(*args)
    @logger << (args)
  end
end

class ParserBase
  include Singleton
  attr_accessor :symbols, :instance, :page, :logger

  def initialize
    # self.instance = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    options = {
      # logger: ChromeHeadlessLogger.new(Logger.new('log/chrome_headless.log', 10, 1024000)),
      pending_connection_errors: false,
      window_size: [1600, 900],
      timeout: 30,
      browser_options: { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false', 'start-maximized': true},
      headless: true,
    }

    if ENV['RACK_ENV'] == 'development'
      options.update(
        headless: true,
        slowmo: 0.5
      )
      self.logger = Logger.new($stdout)
    else
      self.logger = Logger.new('log/chrome_headless.log', 10, 1024000)
    end

    self.instance = Ferrum::Browser.new(options)
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
        logger.error "[#{Thread.current.object_id}] Retrying in #{seconds} seconds because #{$!.full_message}"
        sleep(seconds)
        retry
      end
    ensure
      instance.quit
    end
  end

  def retry_timeout(seconds, waiting_for_if:, when_timeout_do: proc {}, message: '')
    raise 'waiting_for_if must be a Proc object' unless waiting_for_if.is_a? Proc
    raise 'when_timeout_do must be a Proc object' unless when_timeout_do.is_a? Proc

    tries = 0
    begin
      tries += 1
      Timeout.timeout(seconds) do
        loop do
          sleep 0.5
          break unless waiting_for_if.call
        end
      end
    rescue TimeoutError
      logger.info message if message.present?
      logger.info "Timeout after waiting #{seconds} seconds, Retried #{tries} times."
      when_timeout_do.call
      retry
    end
  end

  def timeout(seconds, message: '', &block)
    Timeout.timeout(seconds) do
      loop do
        sleep 0.5
        break unless block.call
      end
    end
  rescue Timeout::Error
    logger.info "Timeout: #{message}!"
  end
end
