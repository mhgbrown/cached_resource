# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cached_resource/version"

Gem::Specification.new do |s|
  s.name        = "Cached Resource"
  s.version     = CachedResource::VERSION
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{Caching for ActiveResource}
  s.description = %q{Enables request-based caching for ActiveResource}

  s.rubyforge_project = "cached_resource"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activeresource"
  s.add_dependency "activesupport"
  s.add_dependency "term-ansicolor"

  s.add_development_dependency "rspec"
end
