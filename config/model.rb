require_relative 'db'
require 'sequel/model'

Sequel::Model.plugin :timestamps
Sequel::Model.plugin :skip_saving_columns
Sequel.extension :symbol_aref
Sequel.extension :fiber_concurrency
DB.extension :pagination
DB.extension :null_dataset

if DB.adapter_scheme == :postgres
  Sequel.extension :store_accessor
  DB.extension :pg_triggers
  DB.extension :pg_json
  DB.extension :pg_streaming
  # DB.stream_all_queries = true
end

Sequel::Model.plugin :subclasses unless RACK_ENV == 'development'

if RACK_ENV == 'development'
  Sequel::Model.cache_associations = false
end

unless RACK_ENV == 'development'
  Sequel::Model.freeze_descendents
  DB.freeze
end
