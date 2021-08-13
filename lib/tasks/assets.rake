namespace :assets do
  desc "Precompile assets"
  task :precompile do
    require_relative '../../config/environment'
    require 'roda/plugins/sprockets_task'
    Roda::RodaPlugins::Sprockets::Task.define!(App)
    Rake::Task['assets:precompile'].invoke
  end

  desc 'Clean assets'
  task :clean do
    require_relative '../../config/environment'
    require 'roda/plugins/sprockets_task'
    Roda::RodaPlugins::Sprockets::Task.define!(App)
    Rake::Task['assets:clean'].invoke
  end
end
