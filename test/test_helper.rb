ENV['RACK_ENV'] = 'test'
require "rack/test"
require 'database_cleaner-sequel'
require_relative '../config/db.rb'

Sequel.extension :migration
Sequel::Migrator.check_current(DB, 'db/migrations')

DatabaseCleaner[:sequel].strategy = :transaction

OUTER_APP = Rack::Builder.parse_file("config.ru").first.freeze

class Minitest::Test
  include Rack::Test::Methods
  def app
    OUTER_APP
  end

  def before_setup
    DatabaseCleaner[:sequel].start
  end

  def after_teardown
    DatabaseCleaner[:sequel].clean
  end
end
