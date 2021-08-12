require 'bundler'
# 在生产环境, 添加export BUNDLE_WITHOUT=development:test, 来跳过所有不需要的 gem
Bundler.require(:default, ENV.fetch('RACK_ENV', "development"))
puts '3'*100
require_relative 'application'
