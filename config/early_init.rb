# load earlier, should be accessible by rake task and app.
require 'pathname'
APP_ROOT = Pathname(Dir.pwd).freeze

# load env

require 'yaml'
env_files = ['Procfile.options', 'Procfile.local']
envs = env_files.filter_map {|file| YAML.load_file(file)['env'] if File.file?(file) }
envs = {}.merge!(*envs).transform_values!(&:to_s)
envs.reject! {|k, _v| ENV.key? k }
ENV.merge!(envs)

# 这行代码是必需的，因为在没有启动 rack 的情况下， ENV['RACK_ENV'] 可能为空
# 而此时，无法判断当前该使用那个环境的 DATABASE_URL.
ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'development'
RACK_ENV = ENV['RACK_ENV'].freeze

# set db url
env_database_url="#{RACK_ENV}_database_url".upcase # e.g DEVELOPMENT_DATABASE_URL
DB_URL = (ENV.delete(env_database_url) || ENV.delete('DATABASE_URL')).freeze

# set logger constant

require 'logger'

case RACK_ENV
when 'development'
  LOGGER = Logger.new($stdout)
when 'production', 'staging'
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::WARN
when 'test'
  LOGGER = Logger.new('log/test.log')
  LOGGER.level = Logger::INFO
end
