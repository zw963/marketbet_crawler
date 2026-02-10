namespace :db do
  task :early_init do |_t, _args|
    require_relative '../../config/early_init'
  end

  task init_db: [:early_init] do |_t, _args|
    require_relative '../../config/db'
    require_relative '../migration_helper'
  end

  task init_models: [:init_db] do |_t, _args|
    require_relative '../../config/model'
    Dir['app/models/**/*.rb'].each {|m| load m }
  end

  desc 'Create database'
  task create: [:early_init] do |_t, _args|
    if DB_URL.start_with? 'sqlite'
      warn 'Do nothing.'
    elsif DB_URL.start_with? 'postgres'
      command = "createdb -U postgres -h 127.0.0.1 -p 5432  #{db_name}"
      warn command
      Kernel.system(command)
      command = "psql -U postgres -h 127.0.0.1 -p 5432 -c \"ALTER USER postgres WITH PASSWORD '#{ENV['POSTGRES_PASSWORD']}';\""
      warn command
      Kernel.system(command)
    end
  end

  desc 'Drop database'
  task drop: [:early_init] do |_t, _args|
    if DB_URL.start_with? 'sqlite'
      FileUtils.rm_f(db_name, verbose: true)
    elsif DB_URL.start_with? 'postgres'
      command = "dropdb -U postgres #{db_name}"
      warn command
      Kernel.system(command)
    end
  end

  desc 'Run migrations'
  task :migrate, [:version] => [:init_db] do |_t, args|
    Sequel.extension :migration
    DB.extension :pg_triggers

    version = args[:version].to_i if args[:version]
    # puts DB.url

    next if Sequel::Migrator.is_current?(DB, 'db/migrations') and version.nil?

    Sequel::Migrator.run(DB, 'db/migrations', target: version)
    task('db:dump').invoke
  end

  desc 'Rollback the last migrate'
  task :rollback, [:number] => [:init_db] do |_t, args|
    if args[:number].nil?
      number = 2
    else
      number = args[:number].to_i + 1
    end
    version = `ls -1v db/migrations/*.rb |tail -n#{number} |head -n1|rev|cut -d'/' -f1|rev|cut -d'_' -f1`.chomp
    puts version
    task('db:migrate').invoke(version)
  end

  desc 'Dump database'
  task dump: [:init_db] do |_t, _args|
    sh "bundle exec sequel -D #{DB.url} > db/schema.rb"
  end

  desc 'Reset database'
  task reset: [:init_db] do |_t, _args|
    Rake::Task['db:drop'].invoke
    sleep 3
    Rake::Task['db:migrate'].reenable
    Rake::Task['db:migrate'].invoke
    # task('db:drop').invoke
    # sleep 3
    # task('db:migrate').invoke
  end

  desc 'Update model annotations'
  task annotate: [:init_models] do
    require 'sequel/annotate'
    Sequel::Annotate.annotate(Dir['app/models/**/*.rb'], border: true)
  end
end

def db_name
  db_pattern = DB_URL.split('//')[1]
  db_pattern.sub(%r{[^:]+:[^:]+@[^:]+:\d+/}, '').split('?')[0]
end
