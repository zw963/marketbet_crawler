# +db.rb+ should contain the minimum code to setup a database connection,
# without loading any of the applications models.
# such as when running migrations.
require_relative 'early_init'

require 'sequel/core'

DB = Sequel.connect(DB_URL, timeout: 10000)
warn "\033[0;34mRACK_ENV=#{ENV['RACK_ENV']}\033[0m"
warn "\033[0;34mDB connected: #{DB_URL}\033[0m"

DB.loggers << LOGGER
