role :app, ["deployer1@152.32.169.103"]
set :branch, 'master'
set :deploy_to, "~/apps/#{fetch(:application)}_#{fetch(:stage)}"
