module CachedResource
  # The Model module is included in ActiveResource::Base and
  # provides methods to enable caching and manipulate the caching
  # configuration
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      
      # initialize cached resource or retrieve the current cached resource configuration
      def cached_resource(options={})
        defined?(@@cached_resource) && @@cached_resource || setup_cached_resource!(options)
      end
      
      private
      
      # setup cached resource for this class by creating a new configuration
      # and establishing the necessary methods.
      def setup_cached_resource!(options)
        @@cached_resource = CachedResource::Configuration.new(options)
        alias_method_chain :find, :cache
        extend CachedResource::Caching
      end
    
    end
    
  end
end