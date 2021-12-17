require 'bundler'

require_relative 'early_init'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, RACK_ENV)
require_relative 'application'
