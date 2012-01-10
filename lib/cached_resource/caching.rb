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

        should_reload ? find_via_reload(key, *arguments) : find_via_cache(key, *arguments)
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
        if object.is_a? Array
          update_singles_cache(object)
          # update the collection only if this is a subset of it
          update_collection_cache(object) unless is_collection?(*arguments)
        else
          update_collection_cache(object)
        end
      end

      # Update the cache of singles with an array of updates.
      def update_singles_cache(updates)
        updates = Array(updates)
        updates.each {|object| cache_write(object.send(primary_key), object)}
      end

      # Update the "mother" collection with an array of updates.
      def update_collection_cache(updates)
        updates = Array(updates)
        collection = cache_read(:all)

        if collection && !updates.empty?
          store = RUBY_VERSION.to_f < 1.9 ? ActiveSupport::OrderedHash.new : {}
          index = collection.inject(store) {|hash, object| hash[object.send(primary_key)] = object; hash}
          updates.each {|object| index[object.send(primary_key)] = object}
          cache_write(:all, index.values)
        end
      end

      # Determine if the given arguments represent
      # the entire collection of objects.
      def is_collection?(*arguments)
        arguments.length == 1 && arguments[0] == :all
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
        result = cached_resource.cache.write(key, object, :expires_in => cached_resource.ttl)
        result && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} WRITE #{key}")
        result
      end

      # Generate the request cache key.
      def cache_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase
      end

    end
  end
end