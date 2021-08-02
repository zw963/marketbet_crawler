role :app, ["deployer1@***REMOVED***"]
set :branch, 'test_cap1'
set :deploy_to, "~/apps/#{fetch(:application)}_#{fetch(:stage)}"
