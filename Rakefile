require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

vendor = File.expand_path("../vendor/neovim", __FILE__)

namespace :neovim do
  desc "Install Neovim"
  task :install do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make"
  end

  desc "Update Neovim installation"
  task :update do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "git clean -fdx && " +
       "git pull origin master && " +
       "make"
  end
end
