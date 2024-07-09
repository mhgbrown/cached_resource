require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec)

task default: [:spec, :standard]
