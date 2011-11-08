require 'stringio'
require 'ostruct'

require 'active_support/concern'
require 'cached_resource/cached_resource'
require 'cached_resource/nilio'
require 'cached_resource/configuration'
require 'cached_resource/caching'
require 'cached_resource/version'

module CachedResource
end

# Include model methods in ActiveResource::Base
class ActiveResource::Base
  include CachedResource::Model
end