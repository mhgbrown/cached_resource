$:.push File.expand_path("../lib", __FILE__)
require "cached_resource/version"

Gem::Specification.new do |s|
  s.name = "cached_resource"
  s.version = CachedResource::VERSION
  s.authors = "Morgan Brown"
  s.email = "cached_resource@email.mhgbrown.is"
  s.homepage = "https://github.com/mhgbrown/cached_resource"
  s.summary = "Caching for ActiveResource"
  s.description = "Enables request-based caching for ActiveResource"
  s.licenses = ["MIT"]

  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*")
  s.executables = Dir.glob("bin/*").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.0"

  s.add_runtime_dependency "activeresource", ">= 6.1"
  s.add_runtime_dependency "msgpack", "~> 1.7", ">= 1.7.3"
  s.add_runtime_dependency "nilio", ">= 1.0"

  s.add_development_dependency "concurrent-ruby"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov", "~> 0.22.0"
  s.add_development_dependency "standard", "~> 1.39", ">= 1.39.1"
  s.add_development_dependency "timecop", "~> 0.9.10"
end
