# +db.rb+ should contain the minimum code to setup a database connection,
# without loading any of the applications models.
# such as when running migrations.

require 'sequel/core'
ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'development'
# e.g DEVELOPMENT_DATABASE_URL
database_url_name="#{ENV['RACK_ENV']}_database_url".upcase
DB = Sequel.connect(ENV.delete(database_url_name) || ENV.delete('DATABASE_URL'), timeout: 10000)
