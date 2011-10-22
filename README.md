# CachedResource 
CachedResource helps ActiveResource by caching responses according to request parameters.  It can help reduce the lag created by making repeated requests across the network.  

## Installation
	gem install cached_resource

## Configuration
CachedResource works "out of the box" with ActiveResource.  By default, it caches responses to an `ActiveSupport::Cache::MemoryStore` and logs to an `ActiveSupport::BufferedLogger` attached to a `StringIO` object.  **In a Rails 3 environment**, CachedResource will attach itself to the Rails logger and cache.

Turn CachedResource off.  This will cause all ActiveResource responses to be retrieved normally (i.e. via the network). 

	CachedResource.off!
	
Turn CachedResource on.

	CachedResource.on!
	
Set the cache expiry time to 60 seconds.

	CachedResource.config.cache_time_to_live = 60
	
Set a different logger.

	CachedResource.config.logger = MyLogger.new
	
Set a different cache store.

	CachedResource.config.cache = MyCacheStore.new

## Usage
Sit back and relax! If you need to reload a particular request you can do something like:

	MyActiveResource.find(:all, :reload => true)

## Testing
	rake

## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)
* latimes and [this plugin](http://github.com/latimes/cached_resource)
