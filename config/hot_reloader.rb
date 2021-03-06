require 'hot_reloader'

loader = Zeitwerk::Loader.new
loader.ignore(
  "#{APP_ROOT}/app/ar",
  "#{APP_ROOT}/app/routes",
  "#{APP_ROOT}/app/helpers",
  "#{APP_ROOT}/app/parsers"
)
loader.push_dir("#{APP_ROOT}/app")
loader.push_dir("#{APP_ROOT}/app/models")
loader.push_dir("#{APP_ROOT}/app/graphql")
loader.push_dir("#{APP_ROOT}/app/services")
loader.inflector.inflect 'ar' => 'AR'

listened_folders = ["#{APP_ROOT}/app/routes", "#{APP_ROOT}/app/helpers"]

if RACK_ENV == 'development'
  HotReloader.will_listen(loader, listened_folders)
else
  puts 'Eager loading ...'
  HotReloader.eager_load(loader)
end
