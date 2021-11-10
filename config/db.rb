# +db.rb+ should contain the minimum code to setup a database connection,
# without loading any of the applications models.
# such as when running migrations.

require 'sequel/core'

require 'pathname'
# load earlier, should be accessible by rake task and app.
APP_ROOT = Pathname(Dir.pwd)

require_relative 'load_env'

# 这行代码是必需的，因为在没有启动 rack 的情况下， RACK_ENV 可能为空
# 而此时，无法判断当前该使用那个环境的 DATABASE_URL.
ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'development'

env_database_url="#{ENV['RACK_ENV']}_database_url".upcase # e.g DEVELOPMENT_DATABASE_URL
db_url = ENV.delete(env_database_url) || ENV.delete('DATABASE_URL')
DB = Sequel.connect(db_url, timeout: 10000)
warn "\033[0;34mRACK_ENV=#{ENV['RACK_ENV']}\033[0m"
warn "\033[0;34mDB connected: #{db_url}\033[0m"

if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
  require 'logger'
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::FATAL if ENV['RACK_ENV'] == 'test'
  DB.loggers << LOGGER
end
