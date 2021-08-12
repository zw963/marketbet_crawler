require_relative 'models'
puts '4'*100
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
