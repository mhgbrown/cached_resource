module CachedResource
  # The Configuration class manages class specific options
  # for cached resource.
  class Configuration < OpenStruct

    # prefix for log messages
    LOGGER_PREFIX = "[cached_resource]"

    # find and set the null file
    FILE_NULL = test(?e, '/dev/null') ? '/dev/null' : 'NUL'

    # default options for cached resource
    DEFAULTS = {
      :enabled => true,
      :ttl => 604800,
      :cache => defined?(Rails.cache)  && Rails.cache || ActiveSupport::Cache::MemoryStore.new,
      :logger => defined?(Rails.logger) && Rails.logger || ActiveSupport::BufferedLogger.new(FILE_NULL)
    }

    # Initialize a Configuration with the given options, overriding any
    # defaults. The following options exist for cached resource:
    # :enabled, default: true
    # :ttl, default: 604800
    # :cache, default: Rails.cache or ActiveSupport::Cache::MemoryStore.new,
    # :logger, default: Rails.logger or ActiveSupport::BufferedLogger.new(StringIO.new)
    def initialize(options={})
      super DEFAULTS.merge(options)
    end

    # enable caching
    def on!
      self.enabled = true
    end

    # disable caching
    def off!
      self.enabled = false
    end

  end
end

