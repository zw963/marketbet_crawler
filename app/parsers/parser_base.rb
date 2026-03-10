require 'singleton'
require 'timeout'

class ParserBase
  include Singleton
  attr_accessor :symbols, :logger

  def initialize
    self.logger = LOGGER
  end

  def run
    tries = 0
    @need_login = true

    begin
      tries += 1
      parse
    rescue
      if tries < 7
        seconds = (1.8**tries).ceil
        logger.error "[#{Thread.current.object_id}] Retrying in #{seconds} seconds because #{$!.full_message}"
        sleep(seconds)
        retry
      end
    ensure
    end
  end
end
