# CachedResource ![Tests](https://github.com/mhgbrown/cached_resource/actions/workflows/ruby.yml/badge.svg)

CachedResource is a Ruby gem designed to enhance the performance of web service interactions through ActiveResource by caching responses based on request parameters. By reducing the need for repeated network requests, it minimizes latency and optimizes the efficiency of your application's data retrieval processes.

## Installation

```ruby
gem install cached_resource
```

## Compatibility

CachedResource is designed to be framework agnostic, but will hook into Rails for caching and logging if available. CachedResource supports the following ActiveSupport/Rails (right) and Ruby (down) version combinations:

|          | 🛤️ 6.1 | 🛤️ 7.0 | 🛤️ 7.1 |
|----------|:------:|:------:|:------:|
| 💎 3.0   |   ✅   |   ✅   |   ✅   |
| 💎 3.1   |   ✅   |   ✅   |   ✅   |
| 💎 3.2   |   ✅   |   ✅   |   ✅   |

## Configuration

**Set up CachedResource across all ActiveResources:**

```ruby
class ActiveResource::Base
  cached_resource(options)
end
```

Or set up CachedResource for a single class:

```ruby
class MyActiveResource < ActiveResource::Base
  cached_resource(options)
end
```

### Options
CachedResource accepts the following options as a hash:

| Option                     | Description                                                                                                                                                         | Default                                                                                                    |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| `:enabled`                 | Enables or disables caching.                                                                                                                                        | `true`                                                                                                     |
| `:cache_collections`       | Set to false to always remake a request for collections.                                                                                                            | `true`                                                                                                     |
| `:cache`                   | The cache store that CacheResource should use.                                                                                                                      | The `Rails.cache` if available, or an `ActiveSupport::Cache::MemoryStore`                                  |
| `:cache_key_prefix`        | A prefix to be added to the cache keys.                                                                                                                              | `nil`                                                                                                      |
| `:collection_arguments`    | The arguments that identify the principal collection request.                                                                                                        | `[:all]`                                                                                                    |
| `:collection_synchronize`  | Use collections to generate cache entries for individuals. Update the existing cached principal collection when retrieving subsets of the principal collection or individuals. | `false`                                                                                                    |
| `:concurrent_write`        | Set to true to make concurrent writes to cache after successful API response. <br>Requires the [concurrent-ruby](https://rubygems.org/gems/concurrent-ruby) gem     | `false`                                                                                                    |
| `:logger`                  | The logger to which CachedResource messages should be written.                                                                                                       | The `Rails.logger` if available, or an `ActiveSupport::Logger`                                             |
| `:race_condition_ttl`      | The race condition ttl, to prevent [dog pile effect](https://en.wikipedia.org/wiki/Cache_stampede) or [cache stampede](https://en.wikipedia.org/wiki/Cache_stampede). | `86400`                                                                                                    |
| `:ttl_randomization_scale` | A Range from which a random value will be selected to scale the ttl.                                                                                                | `1..2`                                                                                                     |
| `:ttl_randomization`       | Enable ttl randomization.                                                                                                                                           | `false`                                                                                                    |
| `:ttl`                     | The time in seconds until the cache should expire.                                                                                                                   | `604800`                                                                                                   |

For example:
```ruby
cached_resource :cache => MyCacheStore.new, :ttl => 60, :collection_synchronize => true, :logger => MyLogger.new
```

#### You can also change them dynamically. Simply:

```ruby
  MyActiveResource.cached_resource.option = option_value
```
For example, to turn CachedResource off
```ruby
  MyActiveResource.cached_resource.off!
```

### Caveats
If you set up CachedResource across all ActiveResources or any subclass of ActiveResource that will be inherited by other classes and you want some of those others to have independent CachedResource configurations, then check out the example below:

```ruby
class ActiveResource::Base
  cached_resource
end
```

```ruby
class MyActiveResource < ActiveResource::Base
  self.cached_resource = CachedResource::Configuration.new(:collection_synchronize: true)
end
```
## Usage
Sit back and relax! If you need to reload a particular request you can pass `:reload => true` into the options hash like this:

```ruby
MyActiveResource.find(:all, :reload => true)
```
If you need to clear the entire cache just do the following:

```ruby
MyActiveResource.clear_cache
```
---
Sometimes you might have a case the resource pathing is non-unique per call. This can create a situation where your caching the same result for multiple calls:

```ruby
MyActiveResource.find(:one, from: "/admin/shop.json")
```

Since resources are cached with an argument based key, you may pass in extra data to be appended to the cache key:

```ruby
MyActiveResource.find(:one, from: "/admin/shop.json", uid: "unique value")
```

## Testing

To test the Ruby + Rails combination configured by default:

```bash
$ rake
```

or to test all supported environments...you have to do a little more work...

Switch your Ruby version to the desired version. This project's maintainer uses `asdf`, so switching to Ruby 3 looks like this:

```bash
$ asdf local ruby 3.0.5
```

If you have a `Gemfile.lock`, delete it:

```bash
$ rm Gemfile.lock
```

Then reinstall your dependencies:

```bash
$ bundle install
```

and finally, run the tests:

```bash
$ rake
```

If you want to test with a specific Rails version, start over and install dependencies with `TEST_RAILS_VERSION` set:

```bash
$ TEST_RAILS_VERSION=6.1 bundle install
```

## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)
* latimes and [this plugin](http://github.com/latimes/cached_resource)

## Feedback/Problems
Feedback is greatly appreciated! Check out this project's [issue tracker](https://github.com/Ahsizara/cached_resource/issues) if you've got anything to say.
