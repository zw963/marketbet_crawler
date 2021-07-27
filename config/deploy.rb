set :application, 'marketbet_crawler'
set :repo_url, 'git@github.com:zw963/marketbet_crawler'
set :rvm_ruby_version, "ruby-2.7.2@#{fetch(:application)}"
set :local_user, -> { Etc.getlogin }
set :linked_dirs, %w{log tmp pids}
set :linked_files, %w{.rvmrc}
