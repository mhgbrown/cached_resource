# CachedResource [![Build Status](https://secure.travis-ci.org/Ahsizara/cached_resource.png)](http://travis-ci.org/Ahsizara/cached_resource)
CachedResource is a Ruby gem whose goal is to increase the performance of interacting with web services via ActiveResource by caching responses based on request parameters.  It can help reduce the lag created by making repeated requests across a network.

## Installation
	gem install cached_resource

## Configuration
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

* `:cache` The cache store that CacheResource should use. Default: The `Rails.cache` if available, or an `ActiveSupport::Cache::MemoryStore`
* `:ttl` The time in seconds until the cache should expire. Default: `604800`
* `:logger` The logger to which CachedResource messages should be written. Default: The `Rails.logger` if available, or an `ActiveSupport::BufferedLogger`
* `:enabled` Default: `true`

You can set them like this:

	cached_resource :cache => MyCacheStore.new, :ttl => 60, :logger => MyLogger.new, :enabled => false

You can also change these options on the fly.

Turn CachedResource off.  This will cause all responses to be retrieved normally (i.e. via the network).

	MyActiveResource.cached_resource.off!

Turn CachedResource on.

	MyActiveResource.cached_resource.on!

Set the cache expiry time to 60 seconds.

	MyActiveResource.cached_resource.ttl = 60

Set a different logger.

	MyActiveResource.cached_resource.logger = MyLogger.new

Set a different cache store.

	MyActiveResource.cached_resource.cache = MyCacheStore.new

## Usage
Sit back and relax! If you need to reload a particular request you can do something like this:

	MyActiveResource.find(:all, :reload => true)

## Testing
	rake

## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)
* latimes and [this plugin](http://github.com/latimes/cached_resource)

## Future Work
* Cached collection lookups
