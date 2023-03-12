require 'singleton'
require 'timeout'

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
  attr_accessor :symbols, :page, :logger, :options, :use_ferrum_directly
  attr_writer :browser, :session

  def initialize
    self.logger = LOGGER

    # self.browser = Ferrum::Browser.new(headless: true, window_size: [1800, 1080], browser_options: {"proxy-server": "socks5://127.0.0.1:22336"})
    options = {
      # logger: ChromeHeadlessLogger.new(Logger.new('log/chrome_headless.log', 10, 1024000)),
      pending_connection_errors: false,
      window_size:               [1600, 900],
      timeout:                   30,
      browser_options:           { 'no-sandbox': nil, 'blink-settings' => 'imagesEnabled=false', 'start-maximized': true},
      headless:                  true,
      slowmo:                    0.5
    }

    if RACK_ENV == 'development'
      options.update(
        headless: false,
        slowmo:   0.5
      )
    end

    self.options = options
  end

  def browser
    if @browser.nil?
      self.use_ferrum_directly = true
      @browser = Ferrum::Browser.new(self.options)
    end

    @browser
  end

  def session
    if @session.nil?
      self.use_ferrum_directly = false
      @session = Capybara::Session.new(:cuprite)
    end

    @session
  end

  def p2b(percent)
    f = percent.tr('%', '').delete(',').delete('$')

    case f
    when 'N/A'
      nil
    when 'No Change'
      BigDecimal('0.0')
    else
      BigDecimal(f) / 100
    end
  end

  def d2b(dollar)
    BigDecimal(dollar.gsub(/GBX|\$|£|,/, ''))
  end

  def run
    tries = 0
    @need_login = true

    begin
      tries += 1
      parse
    rescue Ferrum::TimeoutError, Ferrum::PendingConnectionsError
      if tries < 7
        seconds = (1.8**tries).ceil
        logger.error "[#{Thread.current.object_id}] Retrying in #{seconds} seconds because #{$!.full_message}"
        sleep(seconds)
        if use_ferrum_directly
          browser.quit
        else
          session.driver.browser.quit
        end
        @need_login = true
        retry
      end
    ensure
      if use_ferrum_directly
        browser.quit
      else
        session.driver.browser.quit
      end
    end
  end

  def retry_until_timeout(seconds, keep_waiting_if: proc { true }, keep_waiting_until: proc { false }, when_timeout_do: proc {}, message: '', interval: 2)
    raise 'keep_waiting_if must be a Proc object' unless keep_waiting_if.is_a? Proc
    raise 'keep_waiting_until must be a Proc object' unless keep_waiting_until.is_a? Proc
    raise 'when_timeout_do must be a Proc object' unless when_timeout_do.is_a? Proc

    tries = 0
    begin
      tries += 1
      Timeout.timeout(seconds) do
        loop do
          sleep interval
          break unless keep_waiting_if.call
          break if keep_waiting_until.call
        end
      end
    rescue Timeout::Error
      logger.warn message if message.present?
      logger.warn "Timeout after waiting #{seconds} seconds, Retried #{tries} times."
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
    logger.warn "Timeout: #{message}!"
  end

  def wait_for_valid(&block)
    loop do
      ele = block.call
      break ele if (ele.moving? rescue nil)

      sleep 0.5
    end
  end
end
