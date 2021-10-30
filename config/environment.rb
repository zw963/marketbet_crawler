require 'bundler'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))

require 'yaml'
env_files = ['Procfile.options', 'Procfile.local']
envs = env_files.filter_map {|file| YAML.load_file(file)['env'] if File.file?(file) }
ENV.merge!({}.merge!(*envs))

require_relative 'application'
