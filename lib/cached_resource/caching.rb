module CachedResource
  module Caching
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods

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

      def find_with_read_through_cache(key, *arguments)
        result = Rails.cache.read(key).try(:dup)
        result && log(:read, "#{key} for #{arguments.inspect}")
        result || find_with_reload(key, *arguments)
      end

      def find_with_reload(key, *arguments)
        result = find_without_cache(*arguments)
        Rails.cache.write(key, result, :expires_in => CachedResource.config.cache_time_to_live)
        log(:write, "#{key} for #{arguments.inspect}")
        result
      end

      def cache_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase
      end

      def log(type, msg)
        c = Term::ANSIColor
        type_string = "CachedResource #{type.to_s.classify}"

        case type
        when :read
          type_string = c.blue + c.bold + type_string + c.clear
        when :write
          type_string = c.yellow + c.bold + type_string + c.clear
        end

        Rails.logger.info "#{type_string}  #{msg}"
      end

    end
  end
end