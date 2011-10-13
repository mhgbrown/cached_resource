module CachedResource
  class Config
    include Singleton

    DEFAULT_CACHE_TIME_TO_LIVE = 7.days

    attr_accessor :cache_enabled, :cache_time_to_live

    def initialize
      @cache_enabled = true
      @cache_time_to_live = DEFAULT_CACHE_TIME_TO_LIVE
    end

  end
end