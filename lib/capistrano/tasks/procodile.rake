namespace :deploy do
  desc 'Runs rake db:migrate'
  task :migrate do
    import '../../tasks/sequel.rake'
    on roles(fetch(:procodile_roles, [:app])) do
      within release_path do
        execute :rake, 'db:migrate'
      end
    end
  end
end

after 'deploy:updated', 'deploy:migrate'

namespace :procodile do
  desc 'Start procodile processes'
  task :start do
    on roles(fetch(:procodile_roles, [:app])) do
      rvm_run "procodile start -r #{current_path}"
    end
  end

  desc 'Stop procodile processes'
  task :stop do
    on roles(fetch(:procodile_roles, [:app])) do
      rvm_run "procodile stop -r #{current_path}"
    end
  end

  desc 'Restart procodile processes'
  task :restart do
    on roles(fetch(:procodile_roles, [:app])) do
      rvm_run "procodile restart -r #{current_path}"
    end
  end

  def rvm_run(command, gemset='all')
    # 这里的 all 就是 default gem set.
    # 事实上这里的代码，直接 execute command 也工作的。
    execute "rvm #{fetch(:rvm_ruby_version, gemset)} do #{command}"
  end
end

after 'deploy:finished', "procodile:restart"
