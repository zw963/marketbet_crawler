require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.push_dir("#{__dir__}/../app/models")
loader.inflector.inflect "ar" => "AR"

loader.setup

require_relative 'application'
