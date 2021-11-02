require 'bundler'

require_relative 'load_env'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))
require_relative 'application'
