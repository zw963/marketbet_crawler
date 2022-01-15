require 'database_cleaner-sequel'

# transaction 和 fiber_concurrency 一起不工作, 因此采用 truncation
DatabaseCleaner[:sequel].strategy = :truncation

class Minitest::Test
  def before_setup
    DatabaseCleaner[:sequel].start
  end

  def after_teardown
    DatabaseCleaner[:sequel].clean
  end
end
