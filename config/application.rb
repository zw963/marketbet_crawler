DB = Sequel.connect(ENV.fetch("DATABASE_URL"), timeout: 10000)
Sequel::Model.plugin :timestamps
require 'sequel/extensions/blank'
