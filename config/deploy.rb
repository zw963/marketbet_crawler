set :application, 'marketbet_crawler'
set :repo_url, 'git@github.com:zw963/marketbet_crawler'
set :linked_dirs, %w{log tmp pids public db/files}
set :linked_files, %w{.rvmrc Procfile.local system_config.yml}
set :deploy_to, "~/apps/#{fetch(:application)}_#{fetch(:stage)}"
