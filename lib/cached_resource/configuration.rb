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
      original_ttl = super
      ttl_randomization && original_ttl + original_ttl * sample_range(ttl_randomization_scale) || original_ttl
    end

    # Enables caching.
    def on!
      self.enabled = true
    end

    # Disables caching.
    def off!
      self.enabled = false
    end

    private

    # Choose a random value from within the given range, optionally
    # seeded by seed.
    def sample_range(range, seed=nil)
      srand seed if seed
      rand * (range.end - range.begin) + range.begin
    end

  end
end