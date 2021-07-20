require_relative 'db'
require 'sequel/model'

Sequel::Model.plugin :timestamps
Sequel.extension :symbol_aref
require 'sequel/extensions/blank'

Sequel::Model.plugin :subclasses unless ENV['RACK_ENV'] == 'development'

if ENV['RACK_ENV'] == 'development'
  Sequel::Model.cache_associations = false
end

unless ENV['RACK_ENV'] == 'development'
  Sequel::Model.freeze_descendents
  DB.freeze
end
