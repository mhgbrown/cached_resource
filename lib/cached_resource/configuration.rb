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
    # :collection_synchronize, default: false
    # :cache, default: Rails.cache or ActiveSupport::Cache::MemoryStore.new,
    # :logger, default: Rails.logger or ActiveSupport::BufferedLogger.new(NilIO.new)
    def initialize(options={})
      super({
        :enabled => true,
        :ttl => 604800,
        :collection_synchronize => false,
        :cache => defined?(Rails.cache)  && Rails.cache || CACHE,
        :logger => defined?(Rails.logger) && Rails.logger || LOGGER
      }.merge(options))
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

