require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_group "Lib", "lib/"
  minimum_coverage 100
  refuse_coverage_drop
end

require "rubygems"
require "bundler/setup"
require "active_resource"
require "active_support"
require "active_support/time"
require "cached_resource"
require "support/matchers"
require "pry-byebug"
require "timecop"

RSpec::Matchers.define_negated_matcher :not_change, :change
RSpec.configure do |config|
  # nada
end
