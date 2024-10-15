require "msgpack"
require "nilio"
require "ostruct"

require "active_support/cache"
require "active_support/concern"
require "active_support/logger"
require "cached_resource/cached_resource"
require "cached_resource/configuration"
require "cached_resource/caching"
require "cached_resource/version"
require "active_resource"

module CachedResource
  # nada
end

# Include model methods in ActiveResource::Base
class ActiveResource::Base
  include CachedResource::Model
end
