require 'hot_reloader'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.push_dir("#{__dir__}/../app/models")
loader.ignore("#{__dir__}/../app/ar")
loader.collapse("#{__dir__}/../app/parsers")
loader.inflector.inflect "ar" => "AR"

listened_folders = ["#{__dir__}/../routes"]

if ENV['RACK_ENV'] == 'development'
  HotReloader.will_listen(loader, listened_folders)
else
  HotReloader.eager_load(loader)
end
