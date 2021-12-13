# load env

require 'yaml'
env_files = ['Procfile.options', 'Procfile.local']
envs = env_files.filter_map {|file| YAML.load_file(file)['env'] if File.file?(file) }
envs = {}.merge!(*envs).transform_values!(&:to_s)
envs.reject! {|k, _v| ENV.key? k }
ENV.merge!(envs)

# set logger constant

require 'logger'

case ENV['RACK_ENV']
when 'development'
  LOGGER = Logger.new($stdout)
when 'production', 'staging'
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::WARN
when 'test'
  LOGGER = Logger.new('log/test.log')
  LOGGER.level = Logger::INFO
end
