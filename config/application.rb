require_relative 'models'
require_relative 'hot_reloader'

Thread.report_on_exception = false
App.opts[:root] = File.expand_path('../', __dir__)
