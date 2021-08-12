namespace :assets do
  puts '2'*100
  require_relative '../../config/environment'
  require 'roda/plugins/sprockets_task'

  desc "Precompile assets"
  task :precompile do
    Roda::RodaPlugins::Sprockets::Task.define!(App)
    Rake::Task['assets:precompile'].invoke
  end

  desc 'Clean assets'
  task :clean do
    Roda::RodaPlugins::Sprockets::Task.define!(App)
    Rake::Task['assets:clean'].invoke
  end
end
