# CachedResource [![Build Status](https://secure.travis-ci.org/Ahsizara/cached_resource.png)](http://travis-ci.org/Ahsizara/cached_resource)
CachedResource is a Ruby gem whose goal is to increase the performance of interacting with web services via ActiveResource by caching responses based on request parameters.  It can help reduce the lag created by making repeated requests across a network.

## Installation
	gem install cached_resource

## Compatibility
CachedResource has been tested with the following Ruby versions:

* 1.8.7 [p249] 
* 1.9.2 [p290] 
* 1.9.3 [p0]

CachedResource is designed to be framework agnostic, but will hook into Rails for caching and logging.  It has been tested with the following Rails versions:

* 3.1
* 3.1.3

## Configuration
**Set up CachedResource across all ActiveResources:**

	class ActiveResource::Base
		cached_resource
	end

Or set up CachedResource for a single class:

	class MyActiveResource < ActiveResource::Base
		cached_resource
	end

### Options
CachedResource accepts the following options:

* `:enabled` Default: `true`
* `:ttl` The time in seconds until the cache should expire. Default: `604800`
* `:collection_synchronize` Use collections to generate cache entries for individuals.  Update existing cached collections with new individuals.  Default: `false`
* `:logger` The logger to which CachedResource messages should be written. Default: The `Rails.logger` if available, or an `ActiveSupport::BufferedLogger`
* `:cache` The cache store that CacheResource should use. Default: The `Rails.cache` if available, or an `ActiveSupport::Cache::MemoryStore`

You can set them like this:

	cached_resource :cache => MyCacheStore.new, :ttl => 60, :collection_synchronize => true, :logger => MyLogger.new, :enabled => false

You can also change them on the fly.

Turn CachedResource off.  This will cause all responses to be retrieved normally (i.e. via the network). All responses will still be cached.

	MyActiveResource.cached_resource.off!

Turn CachedResource on.

	MyActiveResource.cached_resource.on!

Set the cache expiry time to 60 seconds.

	MyActiveResource.cached_resource.ttl = 60

Enable collection synchronization.  This will cause a call to `MyActiveResource.all` to also create cache entries for each of its members.  So, for example, a later call to `MyActiveResource.find(1)` will be read from the cache instead of requested from the remote service.

	MyActiveResource.cached_resource.collection_synchronize = true

Set a different logger.

	MyActiveResource.cached_resource.logger = MyLogger.new

Set a different cache store.

	MyActiveResource.cached_resource.cache = MyCacheStore.new

## Usage
Sit back and relax! If you need to reload a particular request you can pass `:reload => true` into the options hash like this:

	MyActiveResource.find(:all, :reload => true)

## Testing
	rake

## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)
* latimes and [this plugin](http://github.com/latimes/cached_resource)

## Feedback/Problems
Feedback is greatly appreciated! Check out this project's [issue tracker](https://github.com/Ahsizara/cached_resource/issues) if you've got anything to say.

## Future Work
* Consider checksums to improve the determination of freshness/changédness
