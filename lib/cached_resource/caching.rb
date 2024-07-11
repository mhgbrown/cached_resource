module CachedResource
  # The Caching module is included in ActiveResource and
  # handles caching and recaching of responses.
  module Caching
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method :find_without_cache, :find
        alias_method :find, :find_with_cache
      end
    end

    module ClassMethods
      # Find a resource using the cache or resend the request
      # if :reload is set to true or caching is disabled.
      def find_with_cache(*arguments)
        arguments << {} unless arguments.last.is_a?(Hash)
        should_reload = arguments.last.delete(:reload) || !cached_resource.enabled
        should_reload = true if !cached_resource.cache_collections && is_any_collection?(*arguments)
        arguments.pop if arguments.last.empty?
        key = cache_key(arguments)

        should_reload ? find_via_reload(key, *arguments) : find_via_cache(key, *arguments)
      end

      # Clear the cache.
      def clear_cache(options = nil)
        if cached_resource.concurrent_write
          Concurrent::Promise.execute { cache_clear(options) }
        else
          cache_clear(options)
        end

        true
      end

      private

      # Try to find a cached response for the given key.  If
      # no cache entry exists, send a new request.
      def find_via_cache(key, *arguments)
        cache_read(key) || find_via_reload(key, *arguments)
      end

      # Re/send the request to fetch the resource
      def find_via_reload(key, *arguments)
        object = find_without_cache(*arguments)
        return object unless should_cache?(object)

        cache_collection_synchronize(object, *arguments) if cached_resource.collection_synchronize
        return object if !cached_resource.cache_collections && is_any_collection?(*arguments)
        cache_write(key, object, *arguments)
        object
      end

      # If this is a pure, unadulterated "all" request
      # write cache entries for all its members
      # otherwise update an existing collection if possible.
      def cache_collection_synchronize(object, *arguments)
        if object.is_a? Enumerable
          update_singles_cache(object, *arguments)
          # update the collection only if this is a subset of it
          update_collection_cache(object, *arguments) unless is_collection?(*arguments)
        else
          update_collection_cache(object, *arguments)
        end
      end

      # Update the cache of singles with an array of updates.
      def update_singles_cache(updates, *arguments)
        updates = Array(updates)
        updates.each { |object| cache_write(cache_key(object.send(primary_key)), object, *arguments) }
      end

      # Update the "mother" collection with an array of updates.
      def update_collection_cache(updates, *arguments)
        updates = Array(updates)
        collection = cache_read(cache_key(cached_resource.collection_arguments))

        if collection && !updates.empty?
          index = collection.each_with_object({}) { |object, hash|
            hash[object.send(primary_key)] = object
          }
          updates.each { |object| index[object.send(primary_key)] = object }
          cache_write(cache_key(cached_resource.collection_arguments), index.values, *arguments)
        end
      end

      # Avoid cache nil or [] objects
      def should_cache?(object)
        return false unless cached_resource.enabled
        object.present?
      end

      # Determine if the given arguments represent
      # the entire collection of objects.
      def is_collection?(*arguments)
        arguments == cached_resource.collection_arguments
      end

      # Determine if the given arguments represent
      # any collection of objects
      def is_any_collection?(*arguments)
        cached_resource.collection_arguments.all? { |arg| arguments.include?(arg) } || arguments.include?(:all)
      end

      # Read a entry from the cache for the given key.
      def cache_read(key)
        object = cached_resource.cache.read(key).try do |json_cache|
          json = ActiveSupport::JSON.decode(json_cache)

          unless json.nil?
            cache = json_to_object(json)
            if cache.is_a? Enumerable
              restored = cache.map { |record| full_dup(record) }
              next restored unless respond_to?(:collection_parser)
              collection_parser.new(restored).tap do |parser|
                parser.resource_class = self
                parser.original_params = json["original_params"].deep_symbolize_keys
              end
            else
              full_dup(cache)
            end
          end
        end
        object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} READ #{key}")
        object
      end

      # Write an entry to the cache for the given key and value.
      def cache_write(key, object, *arguments)
        if cached_resource.concurrent_write
          Concurrent::Promise.execute { _cache_write(key, object, *arguments) } && true
        else
          _cache_write(key, object, *arguments)
        end
      end

      def _cache_write(key, object, *arguments)
        options = arguments[1] || {}
        params = options[:params]
        prefix_options, query_options = split_options(params)

        result = cached_resource.cache.write(key, object_to_json(object, prefix_options, query_options), race_condition_ttl: cached_resource.race_condition_ttl, expires_in: cached_resource.generate_ttl)
        result && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} WRITE #{key}")
        result
      end

      def cache_clear(options = nil)
        if !cached_resource.cache.respond_to?(:delete_matched) || options.try(:fetch, :all)
          cached_resource.cache.clear.tap do |result|
            cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} CLEAR ALL")
          end
        else
          cached_resource.cache.delete_matched(cache_key_delete_pattern).tap do |result|
            cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} CLEAR #{cache_key_delete_pattern}")
          end
        end
      end

      def cache_key_delete_pattern
        case cached_resource.cache
        when ActiveSupport::Cache::MemoryStore, ActiveSupport::Cache::FileStore
          /^#{name_key}\//
        else
          "#{name_key}/*"
        end
      end

      # Generate the request cache key.
      def cache_key(*arguments)
        "#{name_key}/#{arguments.join("/")}".downcase.delete(" ")
      end

      def name_key
        @name_key ||= begin
          prefix = if cached_resource.cache_key_prefix.nil?
            ""
          elsif cached_resource.cache_key_prefix.respond_to?(:call)
            cached_resource.cache_key_prefix.call
          else
            "#{cached_resource.cache_key_prefix}/"
          end
          prefix + name.parameterize.tr("-", "/")
        end
      end

      # Make a full duplicate of an ActiveResource record.
      # Currently just dups the record then copies the persisted state.
      def full_dup(record)
        record.dup.tap do |o|
          o.instance_variable_set(:@persisted, record.persisted?)
        end
      end

      def json_to_object(json)
        resource = json["resource"]
        if resource.is_a? Array
          resource.map do |attrs|
            new(attrs["object"], attrs["persistence"]).tap do |resource|
              resource.prefix_options = json["prefix_options"]
            end
          end
        else
          new(resource["object"], resource["persistence"]).tap do |resource|
            resource.prefix_options = json["prefix_options"]
          end
        end
      end

      def object_to_json(object, prefix_options, query_options)
        if object.is_a? Enumerable
          {
            resource: object.map { |o| {object: o, persistence: o.persisted?} },
            prefix_options: prefix_options,
            original_params: query_options
          }.to_json
        else
          {
            resource: {object: object, persistence: object.persisted?},
            prefix_options: prefix_options
          }.to_json
        end
      end
    end
  end
end
