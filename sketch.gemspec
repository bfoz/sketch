# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
    spec = s
  s.name        = "sketch"
  s.version     = '0.4'
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

    spec.required_ruby_version = '>= 2'

    spec.add_dependency 'geometry', '~> 6.6'

    spec.add_development_dependency "bundler", "~> 2"
    spec.add_development_dependency "rake", "~> 13"
end
