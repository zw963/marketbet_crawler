ENV['RACK_ENV'] = 'test'
require 'warning'

Gem.path.each do |path|
  Warning.ignore(/warning: mismatched indentations at/, path)
  Warning.ignore(/warning: loading in progress, circular require considered harmful/, path)
  Warning.ignore(/warning: method redefined; discarding old absolute_path\?/, path)
end

require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require_relative '../config/db'
# require 'helpers/database_cleaner'
require 'helpers/transaction'

if not Dir.empty?('db/migrations')
  Sequel.extension :migration
  require 'migration_helper'
  include MigrationHelper
  Sequel::Migrator.check_current(DB, 'db/migrations')
end

OUTER_APP = Rack::Builder.parse_file('config.ru').first.freeze.app

class Minitest::Test
  include Rack::Test::Methods
  Fabrication.manager.load_definitions
  alias create Fabricate

  def app
    OUTER_APP
  end

  def query(query_path=nil)
    test_home = APP_ROOT.join('test/graphql').realpath
    current_path = Pathname(caller(1..1).first[/(.*):\d+.*/, 1])
    relative_path = current_path.relative_path_from(test_home)
    name = relative_path.basename.sub(/_test|_spec/, '').sub_ext('.graphql')
    query_file = if query_path
                   APP_ROOT.join("test/graphql_queries/#{query_path}.graphql")
                 else
                   APP_ROOT.join("test/graphql_queries/#{relative_path.dirname}/#{name}")
                 end

    if query_file.exist?
      File.read(query_file)
    else
      raise "#{query_file} 文件不存在."
    end
  end

  def content
    assert_equal(200, last_response.status)

    res = JSON.parse(last_response.body)

    if res.is_a? Array
      res.map { |e| Hashr.new(e) }
    else
      Hashr.new(res)
    end
  rescue JSON::ParserError
    last_response.body
  end

  # def before_all
  #    DB.transaction(:rollback=>:always) do
  #      super
  #    end
  #  end
end
