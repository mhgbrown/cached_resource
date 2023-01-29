# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cached_resource/version"

Gem::Specification.new do |s|
  s.name        = "cached_resource"
  s.version     = CachedResource::VERSION
  s.authors     = "Morgan Brown"
  s.email       = "brown.mhg@gmail.com"
  s.homepage    = "https://github.com/mhgbrown/cached_resource"
  s.summary     = %q{Caching for ActiveResource}
  s.description = %q{Enables request-based caching for ActiveResource}
  s.licenses    = ['MIT']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  puts ENV['TEST_RAILS_VERSION']
  case ENV['TEST_RAILS_VERSION']
  when "4.2"
    # gem "activesupport", "~>4.2.0"
    s.add_runtime_dependency "activeresource"
    s.add_runtime_dependency "activesupport", "~>4.2.0"
  when "5.0"
    # gem "activesupport", "~>5.0.0"
    s.add_runtime_dependency "activeresource"
    s.add_runtime_dependency "activesupport", "~>5.0.0"
  when "5.1"
    # gem "activesupport", "~>5.1.0"
    s.add_runtime_dependency "activeresource"
    s.add_runtime_dependency "activesupport", "~>5.1.0"
  when "6.0"
    # gem "activesupport", "~>6.0.0"
    s.add_runtime_dependency "activeresource"
    s.add_runtime_dependency "activesupport", "~>6.0.0"
  when "6.1"
    # gem "activesupport", "~>6.1.0"
    s.add_runtime_dependency "activeresource"
    s.add_runtime_dependency "activesupport", "~>6.1.0"
  when "7.0"
    # gem "activesupport", "~>7.0.0"
    s.add_runtime_dependency "activeresource"
    s.add_runtime_dependency "activesupport", "~>7.0.0"
  else
    s.add_runtime_dependency "activeresource", ">= 4.0"
    s.add_runtime_dependency "activesupport", ">= 4.0"
  end

  s.add_runtime_dependency "nilio", ">= 1.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "appraisal"
end
