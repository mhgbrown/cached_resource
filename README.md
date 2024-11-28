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

| Option                     | Description                                                                                                                                      | Default                                                                                                   |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| `:enabled`                 | Enables or disables caching.                                                                                                                        | `true`                                                                                                    |
| `:cache_collections`       | Set to `false` to always remake a request for collections.                                                                                          | `true`                                                                                                    |
| `:cache`                   | The cache store that CachedResource should use.                                                                                                     | `Rails.cache` (if available), or an `ActiveSupport::Cache::MemoryStore`.                                 |
| `:cache_key_prefix`        | A prefix to be added to the cache keys.                                                                                                             | `nil`                                                                                                     |
| `:collection_arguments`    | The arguments that identify the principal collection request.                                                                                       | `[:all]`                                                                                                  |
| `:collection_synchronize`  | Use collections to generate cache entries for individuals. Updates the cached principal collection when retrieving subsets or individuals.          | `false`                                                                                                   |
| `:compress`                | Whether to compress cache values using the [`msgpack`](https://rubygems.org/gems/msgpack) gem. The `msgpack` gem must be part of your dependencies. | `false`                                                                                                   |
| `:logger`                  | The logger to which CachedResource messages should be written.                                                                                      | `Rails.logger` (if available), or an `ActiveSupport::Logger`.                                             |
| `:race_condition_ttl`      | The race condition TTL, to prevent the [dog-pile effect](https://en.wikipedia.org/wiki/Cache_stampede) or [cache stampede](https://en.wikipedia.org/wiki/Cache_stampede). | `86400`                                                                                                   |
| `:max_key_length`          | Sets a max key length. Keys exceeding this length will be hashed into a 256-character hex key.                                                      | `nil` (keys are never hashed).                                                                            |
| `:ttl_randomization_scale` | A range from which a random value is selected to scale the TTL.                                                                                     | `1..2`                                                                                                    |
| `:ttl_randomization`       | Enables TTL randomization.                                                                                                                          | `false`                                                                                                   |
| `:ttl`                     | The time in seconds until the cache should expire.                                                                                                  | `604800`                                                                                                  |

For example:
```ruby
cached_resource :cache => MyCacheStore.new, :ttl => 60, :collection_synchronize => true, :logger => MyLogger.new
```

#### You can also change them dynamically. Simply:

```ruby
  MyActiveResource.cached_resource.option = option_value
```

Additionally a couple of helper methods are available:

```ruby
  # Turn caching off
  MyActiveResource.cached_resource.off!
  # Turn caching on
  MyActiveResource.cached_resource.on!
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

## Contribution
### Testing
#### Locally
You can set `TEST_RAILS_VERSION` to a value of the supported Rails versions in the [Compatability Matrix](#compatibility), or bundler will automatically select a version.

Examples:
```sh
TEST_RAILS_VERSION=7.1 bundle exec rspec # runs test suite + linter
bundle exec rspec                        # Runs test suite
```

#### With Docker
```sh
docker build -t cached_resource_test -f Dockerfile.test .
docker run --rm -v  ${PWD}/coverage:/app/coverage cached_resource_test

# Coverage report can be found in coverage/index.html
# RSpec reports can be found in coverage/spec_results/${ruby-version}-${rails-version}.index.html
# Linter reports can be found in coverage/linter-results.index.html
```

### Code Coverage
Coverage can be found found within `coverage/index.html` after every test run.

### Linter
We use unconfigurable linting rules from [Standard](https://github.com/standardrb/standard)

To lint run: `bundle exec rake standard`
To automatically apply linter fixes: `bundle exec rake standard:fix`


## Credit/Inspiration
* quamen and [this gist](http://gist.github.com/947734)

## Feedback/Problems
Feedback is greatly appreciated! Check out this project's [issue tracker](https://github.com/Ahsizara/cached_resource/issues) if you've got anything to say.
