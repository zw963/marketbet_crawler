# e.g DEVELOPMENT_DATABASE_URL
database_url_name="#{ENV.fetch('RACK_ENV', "development").upcase}_DATABASE_URL"
DB = Sequel.connect(ENV.delete(database_url_name) || ENV.delete('DATABASE_URL'), timeout: 10000)
Sequel::Model.plugin :timestamps
Sequel.extension :symbol_aref
require 'sequel/extensions/blank'
