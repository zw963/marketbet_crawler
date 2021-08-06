threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads 1, threads_count
port ENV.fetch("PORT") { 3000 }
log_requests true

file = 'puma'
FileUtils.mkdir_p('tmp/pids')
pidfile "tmp/pids/#{file}.pid"
state_path "tmp/pids/#{file}.state"

FileUtils.mkdir_p('log')
stdout_redirect "log/production.log", "log/#{file}_err.log", true unless ENV['RACK_LOG_TO_STDOUT']

# 当 workers 数量大于 1 时，默认会开启  preload_app! 设定，利用 CoW 节省内存。
# 注意： preload_app! 无法和  phased restart feature 一起使用.
# preload_app!

workers Integer(ENV['WEB_CONCURRENCY'] || 2)

plugin :tmp_restart
