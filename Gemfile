source "http://rubygems.org"

gemspec

puts "\e[93mUsing TEST_RAILS_VERSION #{ENV['TEST_RAILS_VERSION']}\e[0m"
case ENV['TEST_RAILS_VERSION']
when "4.2"
  gem "activeresource"
  gem "activesupport", "~>4.2.0"
when "5.0"
  gem "activeresource"
  gem "activesupport", "~>5.0.0"
when "5.1"
  gem "activeresource"
  gem "activesupport", "~>5.1.0"
when "6.0"
  gem "activeresource"
  gem "activesupport", "~>6.0.0"
when "6.1"
  gem "activeresource"
  gem "activesupport", "~>6.1.0"
when "7.0"
  gem "activeresource"
  gem "activesupport", "~>7.0.0"
else
  puts "\e[93mNo TEST_RAILS_VERSION present, letting dependency manager decide what's best.\e[0m"
end
