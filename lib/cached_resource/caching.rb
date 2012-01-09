module CachedResource
  # The Caching module is included in ActiveResource and
  # handles caching and recaching of responses.
  module Caching
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods
      # Find a resource using the cache or resend the request
      # if :reload is set to true or caching is disabled.
      def find_with_cache(*arguments)
        arguments << {} unless arguments.last.is_a?(Hash)
        should_reload = arguments.last.delete(:reload) || !cached_resource.enabled
        arguments.pop if arguments.last.empty?
        key = cache_key(arguments)

        begin
          (should_reload ? find_via_reload(key, *arguments) : find_via_cache(key, *arguments))
        rescue ActiveResource::ServerError, ActiveResource::ConnectionError, SocketError => e
          raise(e)
        end
      end

      private

      # Try to find a cached response for the given key.  If
      # no cache entry exists, send a new request.
      def find_via_cache(key, *arguments)
        cache_read(key) || find_via_reload(key, *arguments)
      end

      # Re/send the request to fetch the resource. Cache the response
      # for the request.
      def find_via_reload(key, *arguments)
        object = find_without_cache(*arguments)
        cache_collection_synchronize(object, *arguments) if cached_resource.collection_synchronize
        cache_write(key, object)
        object
      end

      # If this is a pure, unadulterated "all" request
      # write cache entries for all its members
      # otherwise update an existing collection if possible.
      def cache_collection_synchronize(object, *arguments)
        if arguments.length == 1 && arguments[0] == :all
          object.each {|r| cache_write(r.send(primary_key), r)}
        elsif !arguments.include?(:all) && (collection = cache_read(:all))
          collection.each_with_index {|member, i| collection[i] = object if member.send(primary_key) == object.send(primary_key)}
          cache_write(:all, collection)
        end
      end

      # Read a entry from the cache for the given key.
      # The key is processed to make sure it is valid.
      def cache_read(key)
        key = cache_key(Array(key)) unless key.is_a? String
        object = cached_resource.cache.read(key).try(:dup)
        object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} READ #{key}")
        object
      end

      # Write an entry to the cache for the given key and value.
      # The key is processed to make sure it is valid.
      def cache_write(key, object)
        key = cache_key(Array(key)) unless key.is_a? String
        cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} WRITE #{key}")
        cached_resource.cache.write(key, object, :expires_in => cached_resource.ttl)
      end

      # generate the request cache key
      def cache_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase
      end

    end
  end
end