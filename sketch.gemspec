# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sketch/version"

Gem::Specification.new do |s|
  s.name        = "sketch"
  s.version     = '0'
  s.authors     = ["Brandon Fosdick"]
  s.email       = ["bfoz@bfoz.net"]
  s.homepage    = "http://github.com/bfoz/sketch"
  s.summary     = %q{2D mechanical sketches}
  s.description = %q{Sketches used in the creation of mechanical designs}

  s.rubyforge_project = "sketch"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
