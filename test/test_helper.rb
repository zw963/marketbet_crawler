ENV['RACK_ENV'] = 'test'
require "rack/test"
require 'database_cleaner-sequel'
require_relative '../config/db'
require 'warning'

Gem.path.each do |path|
  Warning.ignore(/warning: mismatched indentations at/, path)
  Warning.ignore(/warning: loading in progress, circular require considered harmful/, path)
  Warning.ignore(/warning: method redefined; discarding old absolute_path\?/, path)
end

if not Dir.empty?('db/migrations')
  Sequel.extension :migration
  Sequel::Migrator.check_current(DB, 'db/migrations')
end

# transaction 和 fiber_concurrency 一起不工作, 因此采用 truncation
DatabaseCleaner[:sequel].strategy = :truncation

OUTER_APP = Rack::Builder.parse_file("config.ru").first.freeze.app

class Minitest::Test
  include Rack::Test::Methods
  Fabrication.manager.load_definitions
  alias create Fabricate

  def app
    OUTER_APP
  end

  def query(query_path=nil)
    test_home = APP_ROOT.join('test/graphql').realpath
    current_path = Pathname(caller[0][/(.*):\d+.*/, 1])
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
      fail "#{query_file} 文件不存在."
    end
  end

  def content
    assert_equal last_response.status, 200

    res = JSON.parse(last_response.body)

    if res.is_a? Array
      res.map { |e| Hashr.new(e) }
    else
      Hashr.new(res)
    end
  rescue JSON::ParserError
    last_response.body
  end

  def before_setup
    DatabaseCleaner[:sequel].start
  end

  def after_teardown
    DatabaseCleaner[:sequel].clean
  end
end
