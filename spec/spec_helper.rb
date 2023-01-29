require 'rubygems'
require 'bundler/setup'
require 'active_resource'
require 'active_support'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cached_resource'

RSpec.configure do |config|
  # nada
end

require "active_support"
puts
puts "\e[93mUsing ActiveSupport #{ActiveSupport.version}\e[0m"
