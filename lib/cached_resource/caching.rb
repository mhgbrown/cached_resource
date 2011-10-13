module CachedResource
  # The Caching module is included in ActiveResource and
  # handles caching and recaching of responses.
  module Caching
    extend ActiveSupport::Concern

    # when included, setup a middle man for find
    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods

      # find a resource using the cache or resend the request
      # if :reload is set to true or caching is disabled
      def find_with_cache(*arguments)
        options = (arguments.last.is_a?(Hash) ? arguments.last : {})
        should_reload = options.delete(:reload) || !CachedResource.config.cache_enabled
        key = cache_key(arguments)

        begin
          (should_reload ? find_with_reload(key, *arguments) : find_with_read_through_cache(key, *arguments))
        rescue ActiveResource::ServerError, ActiveResource::ConnectionError, SocketError => e
          raise(e)
        end
      end

      private

      # try to find a cached response for the given key.  If
      # no cache entry exists, send a new request.
      def find_with_read_through_cache(key, *arguments)
        result = CachedResource.cache.read(key).try(:dup)
        result && log(:read, "#{key} for #{arguments.inspect}")
        result || find_with_reload(key, *arguments)
      end

      # re/send the request to fetch the resource. Cache the response
      # for the request.
      def find_with_reload(key, *arguments)
        result = find_without_cache(*arguments)
        CachedResource.cache.write(key, result, :expires_in => CachedResource.config.cache_time_to_live)
        log(:write, "#{key} for #{arguments.inspect}")
        result
      end

      # generate the request cache key
      def cache_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase
      end

      # log a message indicating a cached resource event
      def log(type, msg)
        c = Term::ANSIColor
        type_string = "CachedResource #{type.to_s.classify}"

        case type
        when :read
          type_string = c.blue + c.bold + type_string + c.clear
        when :write
          type_string = c.yellow + c.bold + type_string + c.clear
        end

        CachedResource.logger.info "#{type_string}  #{msg}"
      end

    end
  end
end