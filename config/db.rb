# +db.rb+ should contain the minimum code to setup a database connection,
# without loading any of the applications models.
# such as when running migrations.

require 'sequel/core'
# e.g DEVELOPMENT_DATABASE_URL
database_url_name="#{ENV.fetch('RACK_ENV', "development").upcase}_DATABASE_URL"
DB = Sequel.connect(ENV.delete(database_url_name) || ENV.delete('DATABASE_URL'), timeout: 10000)
