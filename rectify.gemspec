require File.expand_path("../lib/rectify/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "rectify"
  s.version       = Rectify::VERSION
  s.summary       = "Improvements for building Rails apps"
  s.description   = "Build Rails apps in a more maintainable way"
  s.authors       = ["Andy Pike"]
  s.email         = "andy@andypike.com"
  s.files         = Dir["LICENSE.txt", "readme.md", "lib/**/*"]
  s.homepage      = "https://github.com/andypike/rectify"
  s.license       = "MIT"
  s.require_paths = ["lib"]

  s.add_dependency "activemodel",   ">= 5.2.3"
  s.add_dependency "activerecord",  ">= 5.2.3"
  s.add_dependency "activesupport", ">= 5.2.3"
  s.add_dependency "virtus",        "~> 1.0.5"
  s.add_dependency "wisper",        "~> 2.0"

  s.add_development_dependency "actionpack",    ">= 5.2.3"
  s.add_development_dependency "awesome_print", "~> 1.8"
  s.add_development_dependency "pry",           "~> 0.12.2"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "rspec-collection_matchers", "~> 1.1"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "sqlite3"
end
