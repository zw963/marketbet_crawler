namespace :assets do
  desc "Precompile the assets"
  task :precompile do
    require_relative '../../config/environment'
    App.compile_assets
  end
end
