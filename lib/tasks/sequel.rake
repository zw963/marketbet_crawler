require 'logger'

namespace :db do
  task :create_db_conn do |t, args|
    require "sequel/core"
    Sequel.extension :migration
    @db = ENV.fetch "DATABASE_URL"
    @conn = Sequel.connect(@db, logger: Logger.new($stderr))
  end

  desc "Create database"
  task :drop => [:create_db_conn] do |t, args|
    database = @conn.opts[:database]
    if @conn.database_type == :sqlite
      FileUtils.rm(database)
    else
      @conn.execute("DROP DATABASE IF EXISTS #{database}")
    end
  end

  desc "Run migrations"
  task :migrate, [:version] => [:create_db_conn] do |t, args|
    version = args[:version].to_i if args[:version]
    Sequel::Migrator.run(@conn, "db/migrations", target: version)
    task('db:dump').invoke
  end

  desc "Dump database"
  task :dump => [:create_db_conn] do |t, args|
    sh "bundle exec sequel -d #{@db} > db/schema.rb"
  end
end
