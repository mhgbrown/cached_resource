module CachedResource
  # The Configuration class manages class specific options
  # for cached resource.
  class Configuration < OpenStruct

    # default or fallback cache without rails
    CACHE = ActiveSupport::Cache::MemoryStore.new

    # default of fallback logger without rails
    LOGGER = ActiveSupport::BufferedLogger.new(NilIO.new)

    # prefix for log messages
    LOGGER_PREFIX = "[cached_resource]"

    # Initialize a Configuration with the given options, overriding any
    # defaults. The following options exist for cached resource:
    # :enabled, default: true
    # :ttl, default: 604800
    # :ttl_randomization, default: false,
    # :ttl_randomization_scale, default: 0..1,
    # :collection_synchronize, default: false,
    # :collection_arguments, default: [:all]
    # :cache, default: Rails.cache or ActiveSupport::Cache::MemoryStore.new,
    # :logger, default: Rails.logger or ActiveSupport::BufferedLogger.new(NilIO.new)
    def initialize(options={})
      super({
        :enabled => true,
        :ttl => 604800,
        :ttl_randomization => false,
        :ttl_randomization_scale => 0..1,
        :collection_synchronize => false,
        :collection_arguments => [:all],
        :cache => defined?(Rails.cache)  && Rails.cache || CACHE,
        :logger => defined?(Rails.logger) && Rails.logger || LOGGER
      }.merge(options))
    end

    # Determine the time until a cache entry should expire.  If ttl_randomization
    # is enabled, then a the set ttl will be added to itself multiplied by a random
    # value from ttl_randomization_scale.
    def ttl
      ttl_randomization && super + super * rand(ttl_randomization_scale) || super
    end

    # Enables caching.
    def on!
      self.enabled = true
    end

    # Disables caching.
    def off!
      self.enabled = false
    end

  end
end