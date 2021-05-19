require 'bundler/setup'
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('../app', __dir__))
loader.push_dir(File.expand_path('../app/models', __dir__))
loader.setup

require_relative 'application'
