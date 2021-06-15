DB = Sequel.connect(ENV.fetch("#{ENV.fetch('RACK_ENV', "development").upcase}_DATABASE_URL"), timeout: 10000)
Sequel::Model.plugin :timestamps
Sequel.extension :symbol_aref
require 'sequel/extensions/blank'
