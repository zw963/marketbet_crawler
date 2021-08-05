role :app, ["deployer2@***REMOVED***"]
set :branch, 'master'
set :deploy_to, "~/apps/#{fetch(:application)}_#{fetch(:stage)}"
