module CachedResource
  # The Configuration class contains global configuration options
  # for CachedResource as well as class specific options.
  class Configuration

    # set default cache time to live to 1 week
    DEFAULT_TTL = 604800

    # prefix for log messages
    LOGGER_PREFIX = "[cached_resource]"

    # options attributes
    ATTRIBUTES = [:enabled, :ttl, :logger, :cache]

    class << self
      attr_accessor *ATTRIBUTES

      # preprare the global configuration with caching enabled and
      # a default cache expiry of 7 days.  Also initializes
      # the logging and caching mechanisms, setting them to
      # the Rails logger and cache if available. If unavailable,
      # sets them to active support equivalents
      def prepare
        @enabled = true
        @ttl = DEFAULT_TTL
        @cache = defined?(Rails.cache)  && Rails.cache || ActiveSupport::Cache::MemoryStore.new
        @logger = defined?(Rails.logger) && Rails.logger || ActiveSupport::BufferedLogger.new(StringIO.new)
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

    attr_accessor *ATTRIBUTES

    # initialize a class specific configuration with the
    # specified options. Falls back to the global configuration
    # if an option is not present.
    def initialize(options={})
      @enabled = options[:enabled] || self.class.enabled
      @ttl = options[:ttl] || self.class.ttl
      @cache = options[:cache] || self.class.cache
      @logger = options[:logger] || self.class.logger
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

