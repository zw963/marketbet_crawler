ENV['RACK_ENV'] = 'test'
require "rack/test"
require 'database_cleaner-sequel'
require_relative '../config/db.rb'

if not Dir.empty?('db/migrations')
  Sequel.extension :migration
  Sequel::Migrator.check_current(DB, 'db/migrations')
end

DatabaseCleaner[:sequel].strategy = :transaction

OUTER_APP = Rack::Builder.parse_file("config.ru").first.freeze.app

class Minitest::Test
  include Rack::Test::Methods
  Fabrication::Support.find_definitions
  alias_method :create, :Fabricate

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
