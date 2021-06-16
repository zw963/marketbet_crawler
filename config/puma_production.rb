threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads 1, threads_count
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RACK_ENV") { "production" }

file = 'puma'
FileUtils.mkdir_p('tmp/pids')
pidfile "tmp/pids/#{file}.pid"
state_path "tmp/pids/#{file}.state"

stdout_redirect "log/production.log", "log/#{file}_err.log", true unless ENV['RACK_LOG_TO_STDOUT']

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
prune_bundler

plugin :tmp_restart
