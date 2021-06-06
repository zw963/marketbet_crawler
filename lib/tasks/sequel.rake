require 'logger'
require "sequel/core"
require_relative '../../config/environment'

namespace :db do
  task :create_db_conn do |t, args|
    Sequel.extension :migration
    DB.logger = Logger.new($stderr)
  end

  desc "Create database"
  task :drop => [:create_db_conn] do |t, args|
    database = DB.opts[:database]
    if DB.database_type == :sqlite
      FileUtils.rm_f(database)
    else
      DB.execute("DROP DATABASE IF EXISTS #{database}")
    end
  end

  desc "Run migrations"
  task :migrate, [:version] => [:create_db_conn] do |t, args|
    version = args[:version].to_i if args[:version]
    puts DB.url
    Sequel::Migrator.run(DB, "db/migrations", target: version)
    task('db:dump').invoke
  end

  desc "Rollback the last migrate"
  task :rollback => [:create_db_conn] do |t, args|
    version=`ls -1v db/migrations/*.rb |tail -n2 |head -n1|rev|cut -d'/' -f1|rev|cut -d'_' -f1`.chomp
    task('db:migrate').invoke(version)
  end

  desc "Dump database"
  task :dump => [:create_db_conn] do |t, args|
    sh "bundle exec sequel -d #{DB.url} > db/schema.rb"
  end

  desc "Reset database"
  task :reset => [:create_db_conn] do |t, args|
    Rake::Task["db:drop"].invoke
    sleep 3
    Rake::Task["db:migrate"].reenable
    Rake::Task["db:migrate"].invoke
    # task('db:drop').invoke
    # sleep 3
    # task('db:migrate').invoke
  end
end
