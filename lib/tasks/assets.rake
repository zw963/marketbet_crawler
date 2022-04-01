namespace :assets do
  desc 'Precompile assets'
  task :precompile do
    require_relative '../../config/environment'
    require 'roda/plugins/sprockets_task'
    Roda::RodaPlugins::Sprockets::Task.define!(App)
    warn 'Precompiling assets'
    Rake::Task['assets:precompile'].invoke
  end

  desc 'Clean assets'
  task :clean do
    require_relative '../../config/environment'
    require 'roda/plugins/sprockets_task'
    Roda::RodaPlugins::Sprockets::Task.define!(App)
    Rake::Task['assets:clean'].invoke
  end

  desc 'deflate assets use brotli'
  task :deflate do
    require_relative '../../config/environment'
    require 'json'
    require 'brotli'
    warn 'Creating brotli compressed assets'
    public_path = App.sprockets_options[:public_path]
    sprockets_manifest_json_file = Dir.glob("#{public_path}/.sprockets-manifest*.json").first
    assets = JSON.load_file(sprockets_manifest_json_file)['assets'].values
    assets.each do |asset|
      asset_file = "#{public_path}/#{asset}"
      writer = Brotli::Writer.new File.open("#{asset_file}.br", 'w')
      writer.write File.read(asset_file)
      writer.close
    end
  end
end
