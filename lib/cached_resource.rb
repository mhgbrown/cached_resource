require 'stringio'

require 'active_support/concern'
require 'cached_resource/cached_resource'
require 'cached_resource/configuration'
require 'cached_resource/caching'
require 'cached_resource/version'

module CachedResource

  # Retrieve the configuration object
  def self.configuration
    @@config ||= CachedResource::Configuration.new(CachedResource::Configuration::DEFAULTS)
  end

  def self.method_missing(meth, *args, &block)
    configuration.respond_to?(meth) && configuration.send(meth, *args, &block) || super
  end

end

# Include model methods in ActiveResource::Base
class ActiveResource::Base
  include CachedResource::Model
end