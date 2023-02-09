require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
require 'ed25519'
install_plugin Capistrano::SCM::Git
require 'capistrano/bundler'
Dir.glob('lib/capistrano/tasks/*.rake').each {|r| import r }
