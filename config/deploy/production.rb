role :app, ["deployer@***REMOVED***"]
set :branch, 'test_cap'
set :deploy_to, "/home/deployer/apps/#{fetch(:application)}_#{fetch(:stage)}"
