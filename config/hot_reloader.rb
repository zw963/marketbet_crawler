require 'hot_reloader'

loader = Zeitwerk::Loader.new
loader.push_dir("#{APP_ROOT}/app")
loader.push_dir("#{APP_ROOT}/app/models")
loader.push_dir("#{APP_ROOT}/app/graphql")
loader.push_dir("#{APP_ROOT}/app/services")
loader.ignore("#{APP_ROOT}/app/ar")
loader.collapse("#{APP_ROOT}/app/parsers")
loader.inflector.inflect "ar" => "AR"

listened_folders = ["#{APP_ROOT}/routes"]

if ENV['RACK_ENV'] == 'development'
  HotReloader.will_listen(loader, listened_folders)
else
  puts 'Eager loading ...'
  HotReloader.eager_load(loader)
end
