require_relative './config/environment'

if ENV['RACK_ENV'] == 'development'
  run ->(env) { App.call(env) }
else
  run App.freeze.app
end
