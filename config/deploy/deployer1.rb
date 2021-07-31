role :app, ["deployer1@152.32.169.103"]
set :branch, 'test_cap1'
set :deploy_to, "~/apps/#{fetch(:application)}_#{fetch(:stage)}"
