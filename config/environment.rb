require 'bundler/setup'
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.push_dir("#{__dir__}/../app/models")

loader.setup

require_relative 'application'
