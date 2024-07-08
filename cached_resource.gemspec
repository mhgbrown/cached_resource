# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cached_resource/version"

Gem::Specification.new do |s|
  s.name        = "cached_resource"
  s.version     = CachedResource::VERSION
  s.authors     = "Morgan Brown"
  s.email       = "cached_resource@email.mhgbrown.is"
  s.homepage    = "https://github.com/mhgbrown/cached_resource"
  s.summary     = %q{Caching for ActiveResource}
  s.description = %q{Enables request-based caching for ActiveResource}
  s.licenses    = ["MIT"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.9.0"

  s.add_runtime_dependency "activeresource", ">= 4.0"
  s.add_runtime_dependency "activesupport", ">= 4.0"
  s.add_runtime_dependency "nilio", ">= 1.0"

  s.add_development_dependency "concurrent-ruby", "~> 1.2", ">= 1.2.3"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov", "~> 0.22.0"
  s.add_development_dependency "timecop", "~> 0.9.10"

end
