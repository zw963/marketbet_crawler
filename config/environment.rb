require 'bundler'
# Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))
# Bundler.setup(:default, :development)
Bundler.setup(:default)

puts $LOAD_PATH.grep(/gruff/)

# loader = Zeitwerk::Loader.new
# loader.push_dir("#{__dir__}/../app")
# loader.push_dir("#{__dir__}/../app/models")

# loader.setup

# require_relative 'application'
