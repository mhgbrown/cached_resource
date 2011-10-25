require 'singleton'
require 'stringio'

require 'active_support/concern'
require 'cached_resource/config'
require 'cached_resource/caching'
require 'cached_resource/version'

module CachedResource

  # Switch cache usage off
  def self.off!
    self.config.enabled = false
  end

  # Switch cache usage on
  def self.on!
    self.config.enabled = true
  end

  # retrieve the configured logger
  def self.logger
    config.logger
  end

  # retrieve the configured cache store
  def self.cache
    config.cache
  end

  # Retrieve the configuration object
  def self.config
    @@config ||= CachedResource::Config.instance
  end

end

# Include caching in ActiveResource::Base
class ActiveResource::Base
  include CachedResource::Caching
end