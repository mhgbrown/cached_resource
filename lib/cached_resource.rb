# sourced from https://gist.github.com/947734
require 'singleton'
require 'term/ansicolor'

require 'active_support/concern'
require 'cached_resource/config'
require 'cached_resource/caching'

module CachedResource

  def self.off!
    self.config.cache_enabled = false
  end

  def self.on!
    self.config.cache_enabled = true
  end

  def self.config
    @@config ||= CachedResource::Config.instance
  end

end

class ActiveResource::Base
  include CachedResource::Caching
end