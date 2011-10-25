module CachedResource
  # The Config class is a singleton that contains
  # global configuration options for CacheResource
  class Config
    include Singleton

    # set default cache time to live to 1 week
    DEFAULT_TTL = 604800

    # prefix for log messages
    LOGGER_PREFIX = "[cached_resource]"

    attr_accessor :enabled, :ttl, :logger, :cache

    # initialize the config with caching enabled and
    # a default cache expiry of 7 days.  Also initializes
    # the logging and caching mechanisms, setting them to
    # the Rails logger and cache if available. If unavailable,
    # sets them to active support equivalents
    def initialize
      @enabled = true
      @ttl = DEFAULT_TTL

      @cache = defined?(Rails.cache)  && Rails.cache || ActiveSupport::Cache::MemoryStore.new
      @logger = defined?(Rails.logger) && Rails.logger || ActiveSupport::BufferedLogger.new(StringIO.new)
    end

  end
end