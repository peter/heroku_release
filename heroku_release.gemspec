# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "heroku_release/version"

Gem::Specification.new do |s|
  s.name        = "heroku_release"
  s.version     = HerokuRelease::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Peter Marklund"]
  s.email       = ["peter@marklunds.com"]
  s.homepage    = "http://rubygems.org/gems/heroku_release"
  s.summary     = %q{Simple RubyGem for tagging and deploying versioned releases of an application to Heroku with the ability to do rollbacks.}

  s.rubyforge_project = "heroku_release"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake", ">= 0.9.2"
  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "mocha", ">= 0.9.9"
end
