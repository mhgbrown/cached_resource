# sourced from this great gist: https://gist.github.com/947734
require 'singleton'
require 'term/ansicolor'

require 'active_support/concern'
require 'cached_resource/config'
require 'cached_resource/caching'
require 'cached_resource/version'

module CachedResource

  # Switch cache usage off
  def self.off!
    self.config.cache_enabled = false
  end

  # Switch cache usage on
  def self.on!
    self.config.cache_enabled = true
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