namespace :db do
  task :init_db do |t, args|
    require_relative '../../config/db'
  end

  task :init_models => [:init_db] do |t, args|
    require_relative '../../config/models'
    Dir['app/models/**/*.rb'].each {|m| load m }
  end

  desc "Drop database"
  task :drop => [:init_db] do |t, args|
    database = DB.opts[:database]
    if DB.database_type == :sqlite
      FileUtils.rm_f(database, verbose: true)
    else
      DB.execute("DROP DATABASE IF EXISTS #{database}")
    end
  end

  desc "Run migrations"
  task :migrate, [:version] => [:init_db] do |t, args|
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    # puts DB.url

    next if Sequel::Migrator.is_current?(DB, 'db/migrations') and version.nil?

    Sequel::Migrator.run(DB, "db/migrations", target: version)
    task('db:dump').invoke
  end

  desc "Rollback the last migrate"
  task :rollback, [:number] => [:init_db] do |t, args|
    if args[:number].nil?
      number = 2
    else
      number = args[:number].to_i + 1
    end
    version=`ls -1v db/migrations/*.rb |tail -n#{number} |head -n1|rev|cut -d'/' -f1|rev|cut -d'_' -f1`.chomp
    puts version
    task('db:migrate').invoke(version)
  end

  desc "Dump database"
  task :dump => [:init_db] do |t, args|
    sh "bundle exec sequel -d #{DB.url} > db/schema.rb"
  end

  desc "Reset database"
  task :reset => [:init_db] do |t, args|
    Rake::Task["db:drop"].invoke
    sleep 3
    Rake::Task["db:migrate"].reenable
    Rake::Task["db:migrate"].invoke
    # task('db:drop').invoke
    # sleep 3
    # task('db:migrate').invoke
  end

  desc "Update model annotations"
  task :annotate => [:init_models] do
    require 'sequel/annotate'
    Sequel::Annotate.annotate(Dir['app/models/**/*.rb'], border: true)
  end
end
