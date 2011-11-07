# CachedResource [![Build Status](https://secure.travis-ci.org/Ahsizara/cached_resource.png)](http://travis-ci.org/Ahsizara/cached_resource)
CachedResource is a Ruby gem whose goal is to increase the performance of interacting with web services via ActiveResource by caching responses based on request parameters.  It can help reduce the lag created by making repeated requests across a network.

## Installation
	gem install cached_resource

## Configuration
By default, CachedResource will cache responses to an `ActiveSupport::Cache::MemoryStore` and logs to an `ActiveSupport::BufferedLogger` attached to a `StringIO` object.  **In a Rails 3 environment**, CachedResource will attach itself to the Rails logger and cache. Check out the options section to see how to change these defaults and more.

Enable CachedResource across all ActiveResources.

	class ActiveResource::Base
		cached_resource
	end

Enable CachedResource for a single class.

	class MyActiveResource < ActiveResource::Base
		cached_resource
	end

### Options
CachedResource accepts the following options:

* `:cache` The cache store that CacheResource should use. Default: `ActiveSupport::Cache::MemoryStore`
* `:ttl` The time in seconds until the cache should expire. Default: `604800`
* `:logger` The logger to which CachedResource messages should be written. Default: `ActiveSupport::BufferedLogger`
* `:enabled` Default: `true`

You can change these options when call `cached_resource`

	cached_resource :cache => MyCacheStore.new, :ttl => 60, :logger => MyLogger.new, :enabled => false

You can also change these options on the fly, both globally and on a class-specific basis.  Class specific options take precedence over global options.

Turn CachedResource off.  This will cause all ActiveResource responses to be retrieved normally (i.e. via the network).

	CachedResource.off!
	MyActiveResource.off!

Turn CachedResource on.

	CachedResource.on!
	MyActiveResource.on!

Set the cache expiry time to 60 seconds.

	CachedResource.ttl = 60
	MyActiveResource.ttl = 60

Set a different logger.

	CachedResource.logger = MyLogger.new
	MyActiveResource.logger = MyLogger.new

Set a different cache store.

	CachedResource.cache = MyCacheStore.new
	MyActiveResource.cache = MyCacheStore.new

## Usage
Sit back and relax! If you need to reload a particular request you can do something like:

	MyActiveResource.find(:all, :reload => true)

## Testing
	rake

## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)
* latimes and [this plugin](http://github.com/latimes/cached_resource)

## Future Work
* Cached collection lookups
