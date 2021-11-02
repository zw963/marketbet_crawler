require 'yaml'
env_files = ['Procfile.options', 'Procfile.local']
envs = env_files.filter_map {|file| YAML.load_file(file)['env'] if File.file?(file) }
envs = {}.merge!(*envs)
envs.reject! {|k, _v| ENV.key? k }
ENV.merge!(envs)
