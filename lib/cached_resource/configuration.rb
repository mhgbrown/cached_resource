module CachedResource
  # The Configuration class manages class specific options
  # for cached resource.
  class Configuration < OpenStruct

    # default or fallback cache without rails
    CACHE = ActiveSupport::Cache::MemoryStore.new

    # default or fallback logger without rails
    LOGGER = ActiveSupport::Logger.new(NilIO.instance)

    # prefix for log messages
    LOGGER_PREFIX = "[cached_resource]"

    # "Internal" variable to represent enabling concurrency
    # so that we know when its value changes.
    attr_reader :concurrent_write

    # Initialize a Configuration with the given options, overriding any
    # defaults. The following options exist for cached resource:
    # :enabled, default: true
    # :ttl, default: 604800
    # :race_condition_ttl: 86400
    # :ttl_randomization, default: false,
    # :ttl_randomization_scale, default: 1..2,
    # :collection_synchronize, default: false,
    # :collection_arguments, default: [:all]
    # :cache, default: Rails.cache or ActiveSupport::Cache::MemoryStore.new,
    # :logger, default: Rails.logger or ActiveSupport::Logger.new(NilIO.new),
    # :cache_collections, default: true
    # :concurrent_write, default: false
    def initialize(options={})
      data = {
        :cache => defined?(Rails.cache)  && Rails.cache || CACHE,
        :cache_collections => true,
        :cache_key_prefix => nil,
        :collection_arguments => [:all],
        :collection_synchronize => false,
        :concurrent_write => false,
        :enabled => true,
        :logger => defined?(Rails.logger) && Rails.logger || LOGGER,
        :race_condition_ttl => 86400,
        :ttl => 604800,
        :ttl_randomization => false,
        :ttl_randomization_scale => 1..2
      }.merge(options)

      # Set our concurrent_write. Can't override OpenStruct setters
      # in a straightforward way.
      # @concurrent_write = data.delete :concurrent_write
      self.concurrent_write = data.delete :concurrent_write
      super(data)
    end

    # Determine the time until a cache entry should expire.  If ttl_randomization
    # is enabled, then a the set ttl will be multiplied by a random
    # value from ttl_randomization_scale.
    def generate_ttl
      ttl_randomization && randomized_ttl || ttl
    end

    # Enables caching.
    def on!
      self.enabled = true
    end

    # Disables caching.
    def off!
      self.enabled = false
    end

    # Toggle writing to cache in a thread. Requires
    # concurrent/promise if enabled.
    def concurrent_write=(value)
      require_concurrent_ruby if value
      @concurrent_write = value
    end

    # require concurrent/promise, throwing an exception if necessary
    def require_concurrent_ruby
      begin
        send :require, 'concurrent/promise'
      rescue LoadError
        @cached_resource.logger.error(
          "`concurrent_write` option is enabled, but `concurrent-ruby` is not an installed dependency"
        )
        raise
      end
    end

    private

    # Get a randomized ttl value between ttl * ttl_randomization_scale begin
    # and ttl * ttl_randomization_scale end
    def randomized_ttl
      ttl * sample_range(ttl_randomization_scale)
    end

    # Choose a random value from within the given range, optionally
    # seeded by seed.
    def sample_range(range, seed=nil)
      srand seed if seed
      rand * (range.end - range.begin) + range.begin
    end

  end
end
