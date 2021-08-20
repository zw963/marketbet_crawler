require_relative 'models'
require_relative 'hot_reloader'

Thread.report_on_exception = false

Opal::Config.source_map_enabled = false unless ENV['RACK_ENV'] == 'development'
