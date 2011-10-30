require 'stringio'

require 'active_support/concern'
require 'cached_resource/config'
require 'cached_resource/caching'
require 'cached_resource/version'

module CachedResource

  # Switch cache usage on
  def self.on!
    CachedResource::Configuration.on!
  end

  # Switch cache usage off
  def self.off!
    CachedResource::Configuration.off!
  end

  # Retrieve the configuration object
  def self.config
    CachedResource::Configuration
  end

end

# Include model methods in ActiveResource::Base
class ActiveResource::Base
  include CachedResource::Model
end