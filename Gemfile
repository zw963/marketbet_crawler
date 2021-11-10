source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'hot_reloader'
gem "ferrum"
gem 'terminal-table'
gem 'sequel_pg', require: 'sequel'
gem 'sequel-annotate'
gem 'pg'
gem 'sqlite3'
gem 'only_blank'
gem 'interactor'
gem 'roda'
gem 'falcon'
gem 'tilt'
gem 'rake'
gem 'rack-test', require: false

# templates
gem 'erubi', '>= 1.5'
gem 'sassc'
gem 'terser'
gem 'brotli'
gem 'opal'
gem "opal-sprockets"
gem "roda-sprockets"
gem 'snabberb'
# gem 'paggio', github: 'hmdne/paggio'
gem 'opal-browser', github: 'opal/opal-browser'
gem 'refrigerator'
gem 'graphql'

group :development do
  gem 'gruff', group: :development
  # gem 'activerecord', require: 'active_record'
  # gem 'pry-rescue'
  gem 'roda-enhanced_logger'
  gem 'puma'
end

group :test do
  gem 'database_cleaner-sequel'
  gem 'minitest-global_expectations'
  gem 'timecop'
  gem 'fabrication'
  gem 'hashr'
  gem 'warning'
  gem 'm'
end
