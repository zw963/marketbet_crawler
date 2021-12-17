require_relative './config/environment'

if RACK_ENV == 'development'
  # require 'pry-rescue/rack'
  # Roda.use PryRescue::Rack
  run ->(env) { App.call(env) }
else
  run App.freeze.app
  Refrigerator.freeze_core(:except=>['Gem', 'Object']) if RACK_ENV == 'production'
end
