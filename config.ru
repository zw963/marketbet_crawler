require_relative './config/environment'

if ENV['RACK_ENV'] == 'development'
  require 'pry-rescue/rack'
  # Roda.use PryRescue::Rack
  run ->(env) { App.call(env) }
else
  run App.freeze.app
  Refrigerator.freeze_core(:except=>['Gem', 'Object']) if ENV['RACK_ENV'] == 'production'
end
