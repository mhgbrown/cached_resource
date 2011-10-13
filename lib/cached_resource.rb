# sourced from https://gist.github.com/947734
require 'singleton'
require 'term/ansicolor'

require 'active_support/concern'
require 'cached_resource/config'
require 'cached_resource/caching'

module CachedResource

  # Switch caching off
  def self.off!
    self.config.cache_enabled = false
  end

  # Switch caching on
  def self.on!
    self.config.cache_enabled = true
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