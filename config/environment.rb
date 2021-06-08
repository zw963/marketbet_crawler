require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))
require_relative 'application'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.push_dir("#{__dir__}/../app/models")
loader.inflector.inflect "ar" => "AR"

if ENV['RACK_ENV'] == 'production'
  HotReloader.eager_load(loader)
else
  HotReloader.will_listen(loader)
end
