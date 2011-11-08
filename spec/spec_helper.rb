require 'rubygems'
require 'bundler/setup'

require 'active_resource'
require 'active_support'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cached_resource'


RSpec.configure do |config|
  # nada
end

# change the logger so that we log to STDOUT
# CachedResource.logger = ActiveSupport::BufferedLogger.new(STDOUT)