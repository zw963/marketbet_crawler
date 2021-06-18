require 'hot_reloader'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.push_dir("#{__dir__}/../app/models")
loader.ignore("#{__dir__}/../app/ar")
loader.collapse("#{__dir__}/../app/parsers")
loader.inflector.inflect "ar" => "AR"

if ENV['RACK_ENV'] == 'production'
  HotReloader.eager_load(loader)
else
  HotReloader.will_listen(loader)
end
