# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'pry-rescue', require: false
gem 'hot_reloader'
gem "ferrum"
gem 'terminal-table'
gem 'sequel'
gem 'sequel-annotate'
gem 'sqlite3'

gem 'roda'
gem 'puma'
gem 'tilt'
gem 'erubi', '>= 1.5'
gem 'thamble'
gem 'rake'
# gem 'awesome_print'
gem 'rack-test', require: false
# gem 'http'
# gem 'faraday'

group :development do
  gem 'gruff', group: :development
  # gem 'activerecord', require: 'active_record'
end

group :test do
  gem 'database_cleaner-sequel'
  gem 'minitest-global_expectations'
end

group :production, :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
end
