source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'hot_reloader'
gem 'terminal-table'
gem 'sequel_pg', require: 'sequel'
gem 'sequel-annotate'
gem 'sequel_postgresql_triggers'
gem 'sequel-store'
gem 'pg'
gem 'sqlite3'
gem 'only_blank'
gem 'service_actor'
# gem 'dry-monads', require: 'dry/monads/all'
gem 'roda'
gem 'tilt'
gem 'rake', '13.0.6'
gem 'rack-test', require: false

# templates
gem 'erubi', '>= 1.5'
gem 'sassc'
gem 'terser'
gem 'brotli'
gem 'opal'
gem 'opal-browser'
gem "opal-sprockets"
gem "roda-sprockets"
gem 'snabberb'
# gem 'paggio', github: 'hmdne/paggio'
gem 'refrigerator'
gem 'graphql'

group :development do
  gem 'gruff', group: :development
  # gem 'activerecord', require: 'active_record'
  # gem 'pry-rescue'
  gem 'roda-enhanced_logger'
end

group :test do
  gem 'minitest'
  gem 'm'
  gem 'database_cleaner-sequel'
  gem 'timecop'
  gem 'fabrication'
  gem 'hashr'
  gem 'warning'
end

# group :development, :test do
gem "ferrum"
gem 'cuprite'
gem 'capybara'
# end

group :production do
  gem 'falcon'
end

gem 'puma'
