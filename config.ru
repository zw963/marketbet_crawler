require_relative './config/environment'

if ENV['RACK_ENV'] == 'production'
  run App.freeze.app
else
  run ->(env) { App.call(env) }
end
