source "http://rubygems.org"

gemspec

def eval_gemfile(path)
  gemfile_local = File.expand_path(path, __FILE__)
  if File.readable?(gemfile_local)
    puts "Loading #{gemfile_local}..." if $DEBUG
    instance_eval(File.read(gemfile_local))
  end
end

puts "\e[93mUsing TEST_RAILS_VERSION #{ENV['TEST_RAILS_VERSION']}\e[0m"
case ENV['TEST_RAILS_VERSION']
when "4.2"
  # gem "rails", "~>4.2.0"
  eval_gemfile('./gemfiles/4.2.gemfile')
when "5.0"
  gem "rails", "~>5.0.0"
when "5.1"
  gem "rails", "~>5.1.0"
when "6.0"
  gem "rails", "~>6.0.0"
when "6.1"
  gem "rails", "~>6.1.0"
when "7.0"
  gem "rails", "~>7.0.0"
else
  puts "\e[93mNo TEST_RAILS_VERSION present, letting dependency manager decide what's best.\e[0m"
end
