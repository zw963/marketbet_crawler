source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'hot_reloader'
gem "ferrum"
gem 'terminal-table'
gem 'sequel'
gem 'sequel-annotate'
gem 'sqlite3'
gem 'only_blank'
gem 'interactor'

gem 'roda'
gem 'puma'
gem 'tilt'
gem 'rake'
gem 'rack-test', require: false

# templates
gem 'erubi', '>= 1.5'
gem 'sassc'
gem 'terser'
gem 'brotli'
gem "opal-sprockets"
gem "roda-sprockets", github: 'hmdne/roda-sprockets'
gem 'snabberb'
# gem 'paggio', github: 'hmdne/paggio'
gem 'opal-browser', github: 'opal/opal-browser'
gem 'refrigerator'
gem 'graphql'

group :development do
  gem 'gruff', group: :development
  # gem 'activerecord', require: 'active_record'
  gem 'pry-rescue'
end

group :test do
  gem 'database_cleaner-sequel'
  gem 'minitest-global_expectations'
  gem 'timecop'
  gem 'fabrication'
  gem 'hashr'
end
