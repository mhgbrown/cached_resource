require 'rubygems'
require 'bundler/setup'
require 'active_resource'
require 'active_support'
require 'active_support/time'
require 'concurrent/promise'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cached_resource'

RSpec.configure do |config|
  # nada
end

