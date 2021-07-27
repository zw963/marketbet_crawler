namespace :db do
  task :init do |t, args|
    # require_relative 'hot_reloader' unless defined? HotReloader
    require_relative '../../config/db'
    Sequel.extension :migration
  end

  desc "Drop database"
  task :drop => [:init] do |t, args|
    database = DB.opts[:database]
    if DB.database_type == :sqlite
      puts "rm -f #{database}"
      FileUtils.rm_f(database)
    else
      DB.execute("DROP DATABASE IF EXISTS #{database}")
    end
  end

  desc "Run migrations"
  task :migrate, [:version] => [:init] do |t, args|
    version = args[:version].to_i if args[:version]
    puts DB.url
    if !Sequel::Migrator.is_current?(DB, 'db/migrations') and version.nil?
      Sequel::Migrator.run(DB, "db/migrations", target: version)
      task('db:dump').invoke
    end
  end

  desc "Rollback the last migrate"
  task :rollback => [:init] do |t, args|
    version=`ls -1v db/migrations/*.rb |tail -n2 |head -n1|rev|cut -d'/' -f1|rev|cut -d'_' -f1`.chomp
    task('db:migrate').invoke(version)
  end

  desc "Dump database"
  task :dump => [:init] do |t, args|
    sh "bundle exec sequel -d #{DB.url} > db/schema.rb"
  end

  desc "Reset database"
  task :reset => [:init] do |t, args|
    Rake::Task["db:drop"].invoke
    sleep 3
    Rake::Task["db:migrate"].reenable
    Rake::Task["db:migrate"].invoke
    # task('db:drop').invoke
    # sleep 3
    # task('db:migrate').invoke
  end
end
