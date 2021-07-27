role :app, ["deployer@152.32.169.103"]
set :branch, 'test_cap'
set :deploy_to, "/home/deployer/apps/#{fetch(:application)}_#{fetch(:stage)}"
