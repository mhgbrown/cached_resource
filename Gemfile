source "http://rubygems.org"

gemspec

def eval_gemfile(path)
  gemfile_local = File.expand_path(path, __FILE__)
  if File.readable?(gemfile_local)
    puts "Loading #{gemfile_local}..." if ENV['DEBUG']
    instance_eval(File.read(gemfile_local))
  end
end

puts "\e[93mUsing TEST_RAILS_VERSION #{ENV['TEST_RAILS_VERSION']}\e[0m" if ENV['DEBUG']
case ENV['TEST_RAILS_VERSION']
when "4.2"
  eval_gemfile('../gemfiles/4.2.gemfile')
when "5.0"
  eval_gemfile('../gemfiles/5.0.gemfile')
when "5.1"
  eval_gemfile('../gemfiles/5.1.gemfile')
when "6.0"
  eval_gemfile('../gemfiles/6.0.gemfile')
when "6.1"
  eval_gemfile('../gemfiles/6.1.gemfile')
when "7.0"
  eval_gemfile('../gemfiles/7.0.gemfile')
when "7.1"
  eval_gemfile('../gemfiles/7.1.gemfile')
else
  puts "\e[93mNo TEST_RAILS_VERSION present, letting dependency manager decide what's best.\e[0m" if ENV['DEBUG']
end
