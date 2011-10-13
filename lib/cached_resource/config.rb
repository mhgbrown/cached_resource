module CachedResource
  # The Config class is a singleton that contains
  # global configuration options for CacheResource
  class Config
    include Singleton

    DEFAULT_CACHE_TIME_TO_LIVE = 7.days

    attr_accessor :cache_enabled, :cache_time_to_live, :logger, :cache

    # initialize the config with caching enabled and
    # a default cache expiry of 7 days.  Also initializes
    # the logging and caching mechanisms, setting them to
    # the Rails logger and cache if available. If unavailable,
    # sets them to active support equivalents
    def initialize
      @cache_enabled = true
      @cache_time_to_live = DEFAULT_CACHE_TIME_TO_LIVE

      @cache = defined?(Rails.cache)  && Rails.cache || ActiveSupport::Cache::MemoryStore.new)
      @logger = defined?(Rails.logger) && Rails.logger || ActiveSupport::BufferedLogger.new(STDERR)
    end

  end
end