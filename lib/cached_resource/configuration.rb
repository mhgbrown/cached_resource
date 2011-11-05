module CachedResource
  # The Configuration class contains global configuration options
  # for CachedResource as well as class specific options.
  class Configuration

    # options attributes
    ATTRIBUTES = [:enabled, :ttl, :logger, :cache]

    # default options for cached resource
    DEFAULTS = {
      :enabled => true,
      :ttl => 604800,
      :cache => defined?(Rails.cache)  && Rails.cache || ActiveSupport::Cache::MemoryStore.new,
      :logger => defined?(Rails.logger) && Rails.logger || ActiveSupport::BufferedLogger.new(StringIO.new)
    }

    # prefix for log messages
    LOGGER_PREFIX = "[cached_resource]"

    attr_accessor *ATTRIBUTES

    # initialize a configuration with the specified options.
    # Falls back to the global configuration if an option is not present.
    def initialize(options={})
      @enabled = options[:enabled] || CachedResource.enabled
      @ttl = options[:ttl] || CachedResource.ttl
      @cache = options[:cache] || CachedResource.cache
      @logger = options[:logger] || CachedResource.logger
    end

    # enable caching
    def on!
      enabled = true
    end

    # disable caching
    def off!
      enabled = false
    end

  end
end

