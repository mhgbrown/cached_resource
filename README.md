# CachedResource [![Build Status](https://secure.travis-ci.org/Ahsizara/cached_resource.png)](http://travis-ci.org/Ahsizara/cached_resource)
CachedResource is a Ruby gem whose goal is to increase the performance of interacting with web services via ActiveResource by caching responses based on request parameters.  It can help reduce the lag created by making repeated requests across a network.

## Installation
	gem install cached_resource

## Compatibility
CachedResource supports the following Ruby versions:

* 1.9.2, 1.9.3
* 2.0.0, 2.1.0

If you require 1.8.7 support, please use version 2.3.4.

CachedResource is designed to be framework agnostic, but will hook into Rails for caching and logging if available. CachedResource officially supports the following Rails versions:

* 3.2.x
* 4.0.0
* 4.1.x

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
* `:race_condition_ttl` The race condition ttl, to prevent `dog pile effect(https://en.wikipedia.org/wiki/Cache_stampede)` or `cache stampede(https://en.wikipedia.org/wiki/Cache_stampede)`. Default: 86400
* `:ttl_randomization` Enable ttl randomization. Default: `false`
* `:ttl_randomization_scale` A Range from which a random value will be selected to scale the ttl. Default: `1..2`
* `:collection_synchronize` Use collections to generate cache entries for individuals.  Update the existing cached principal collection when retrieving subsets of the principal collection or individuals.  Default: `false`
* `:collection_arguments` The arguments that identify the principal collection request. Default: `[:all]`
* `:logger` The logger to which CachedResource messages should be written. Default: The `Rails.logger` if available, or an `ActiveSupport::BufferedLogger`
* `:cache` The cache store that CacheResource should use. Default: The `Rails.cache` if available, or an `ActiveSupport::Cache::MemoryStore`

You can set them like this:

	cached_resource :cache => MyCacheStore.new, :ttl => 60, :collection_synchronize => true, :logger => MyLogger.new

You can also change them on the fly.

Turn CachedResource off.  This will cause all responses to be retrieved normally (i.e. via the network). All responses will still be cached.

	MyActiveResource.cached_resource.off!

Turn CachedResource on.

	MyActiveResource.cached_resource.on!

Set the cache expiry time to 60 seconds.

	MyActiveResource.cached_resource.ttl = 60

Enable cache expiry time randomization, allowing it to fall randomly between 60 and 120 seconds.

	MyActiveResource.cached_resource.ttl_randomization = true

Change the cache expiry time randomization scale so that the cache expiry time falls randomly between 30 and 180 seconds.

	MyActiveResource.cached_resource.ttl_randomization_scale = 0.5..3

Enable collection synchronization.  This will cause a call to `MyActiveResource.all` to also create cache entries for each of its members.  So, for example, a later call to `MyActiveResource.find(1)` will be read from the cache instead of requested from the remote service.

	MyActiveResource.cached_resource.collection_synchronize = true

Change the arguments that identify the principal collection request.  If for some reason you are concerned with a collection that is retrieved at a "non-standard" URL, you may specify the Ruby arguments that produce that URL.  When `collection_synchronize` is `true`, the collection returned from a request that matches these arguments will be cached and later updated when one of its members or a subset is retrieved.

	MyActiveResource.cached_resource.collection_arguments = [:all, :params => {:name => "Bob"}]

Set a different logger.

	MyActiveResource.cached_resource.logger = MyLogger.new

Set a different cache store.

	MyActiveResource.cached_resource.cache = MyCacheStore.new

### Caveats
If you set up CachedResource across all ActiveResources or any subclass of ActiveResource that will be inherited by other classes and you want some of those others to have independent CachedResource configurations, then check out the example below:

	class ActiveResource::Base
		cached_resource
	end

	class MyActiveResource < ActiveResource::Base
		self.cached_resource = CachedResource::Configuration.new(:collection_synchronize => true)
	end

## Usage
Sit back and relax! If you need to reload a particular request you can pass `:reload => true` into the options hash like this:

	MyActiveResource.find(:all, :reload => true)

If you need to clear the entire cache just do the following:

	MyActiveResource.clear_cache

---
Sometimes you might have a case the resource pathing is non-unique per call. This can create a situation where your caching the same result for multiple calls:

	MyActiveResource.find(:one, from: "/admin/shop.json")

Since resources are cached with an argument based key, you may pass in extra data to be appended to the cache key:
  
	MyActiveResource.find(:one, from: "/admin/shop.json", uid: "unique value")
  
## Testing
	rake

## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)
* latimes and [this plugin](http://github.com/latimes/cached_resource)

## Feedback/Problems
Feedback is greatly appreciated! Check out this project's [issue tracker](https://github.com/Ahsizara/cached_resource/issues) if you've got anything to say.

## Future Considerations
This may change at any time.

* Callbacks on before and after reload
* Consider checksums to improve the determination of freshness/changédness




