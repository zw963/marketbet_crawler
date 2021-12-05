require 'hot_reloader'

loader = Zeitwerk::Loader.new
loader.push_dir("#{APP_ROOT}/app/parsers")
HotReloader.eager_load(loader)
