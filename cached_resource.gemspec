# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cached_resource/version"

Gem::Specification.new do |s|
  s.name        = "cached_resource"
  s.version     = CachedResource::VERSION
  s.authors     = "Andrew Chan"
  s.email       = "email@suspi.net"
  s.homepage    = "http://github.com/Ahsizara/cached_resource"
  s.summary     = %q{Caching for ActiveResource}
  s.description = %q{Enables request-based caching for ActiveResource}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activeresource"
  s.add_dependency "activesupport"
  s.add_dependency "term-ansicolor"

  s.add_development_dependency "rspec"
end
