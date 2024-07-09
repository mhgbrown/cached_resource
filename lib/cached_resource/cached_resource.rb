module CachedResource
  # The Model module is included in ActiveResource::Base and
  # provides methods to enable caching and manipulate the caching
  # configuration
  module Model
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :cached_resource

        # Initialize cached resource or retrieve the current cached resource configuration.
        def cached_resource(options={})
          defined?(@cached_resource) && @cached_resource || setup_cached_resource!(options)
        end

        # Set up cached resource for this class by creating a new configuration
        # and establishing the necessary methods.
        def setup_cached_resource!(options)
          @cached_resource = CachedResource::Configuration.new(options)
          if @cached_resource.concurrent_write
            @cached_resource.require_concurrent_ruby
            # begin
            #   send :require, 'concurrent/promise'
            # rescue LoadError
            #   @cached_resource.logger.error(
            #     "`concurrent_write` option is enabled, but `concurrent-ruby` is not an installed dependency"
            #   )
            #   raise
            # end
          end
          send :include, CachedResource::Caching
          @cached_resource
        end
      end
    end

    module ClassMethods
      # Copy a superclass's cached resource configuration if
      # it's defined.  Unfortunately, this means that any subclass
      # that wants an independent configuration will need to execute:
      # self.cached_resource = CachedResource::Configuration.new(options={})
      def inherited(child)
        child.cached_resource = self.cached_resource if defined?(@cached_resource)
        super
      end
    end
  end
end
