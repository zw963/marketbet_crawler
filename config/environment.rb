require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))
require_relative 'application'
require_relative 'hot_reloader'
