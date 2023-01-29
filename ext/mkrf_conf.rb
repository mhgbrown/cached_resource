require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb'

begin
  Gem::Command.build_args = ARGV
  rescue NoMethodError
end

inst = Gem::DependencyInstaller.new
# begin
#   if RUBY_VERSION < "1.9"
#     inst.install "ruby-debug-base", "~> 0.10.3"
#   else
#     inst.install "ruby-debug-base19", "~> 0.11.24"
#   end
#   rescue
#     exit(1)
# end

begin
  puts ENV['TEST_RAILS_VERSION']
  case ENV['TEST_RAILS_VERSION']
  when "4.2"
    # gem "activesupport", "~>4.2.0"
    # s.add_runtime_dependency "activeresource"
    inst.install "activesupport", "~>4.2.0"
    inst.install "activeresource"
  when "5.0"
    # gem "activesupport", "~>5.0.0"
    # s.add_runtime_dependency "activeresource"
    # s.add_runtime_dependency "activesupport", "~>5.0.0"
    inst.install "activesupport", "~>5.0.0"
    inst.install "activeresource"
  when "5.1"
    # gem "activesupport", "~>5.1.0"
    # s.add_runtime_dependency "activeresource"
    # s.add_runtime_dependency "activesupport", "~>5.1.0"
    inst.install "activesupport", "~>5.1.0"
    inst.install "activeresource"
  when "6.0"
    # gem "activesupport", "~>6.0.0"
    # s.add_runtime_dependency "activeresource"
    # s.add_runtime_dependency "activesupport", "~>6.0.0"
    inst.install "activesupport", "~>6.0.0"
    inst.install "activeresource"
  when "6.1"
    # gem "activesupport", "~>6.1.0"
    # s.add_runtime_dependency "activeresource"
    # s.add_runtime_dependency "activesupport", "~>6.1.0"
    inst.install "activesupport", "~>6.1.0"
    inst.install "activeresource"
  when "7.0"
    # gem "activesupport", "~>7.0.0"
    # s.add_runtime_dependency "activeresource"
    # s.add_runtime_dependency "activesupport", "~>7.0.0"
    inst.install "activesupport", "~>7.0.0"
    inst.install "activeresource"
  else
    puts 'Nothing to do'
  end
rescue
  exit(1)
end

f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")   # create dummy rakefile to indicate success
f.write("task :default\n")
f.close
