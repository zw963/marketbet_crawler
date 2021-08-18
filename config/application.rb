require_relative 'models'
require_relative 'hot_reloader'

Thread.report_on_exception = false

# For disable Rack::Lint
module Rack
  class Lint
    def call(env = nil)
      @app.call(env)
    end
  end
end

Opal::Config.source_map_enabled = false unless ENV['RACK_ENV'] == 'development'
