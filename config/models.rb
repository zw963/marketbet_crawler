require_relative 'db'
require 'sequel/model'

Sequel::Model.plugin :subclasses unless ENV['RACK_ENV'] == 'development'

if ENV['RACK_ENV'] == 'development'
  Sequel::Model.cache_associations = false
end

if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
  require 'logger'
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::FATAL if ENV['RACK_ENV'] == 'test'
  DB.loggers << LOGGER
end

unless ENV['RACK_ENV'] == 'development'
  Sequel::Model.freeze_descendents
  DB.freeze
end
