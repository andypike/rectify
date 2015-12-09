require File.expand_path("../lib/rectify/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "rectify"
  s.version       = Rectify::VERSION
  s.date          = "2015-12-08"
  s.summary       = "Improvements for building Rails apps"
  s.description   = "Build Rails apps in a more maintainable way"
  s.authors       = ["Andy Pike"]
  s.email         = "andy@andypike.com"
  s.files         = Dir["LICENSE.txt", "readme.md", "lib/**/*"]
  s.homepage      = "https://github.com/andypike/rectify"
  s.license       = "MIT"
  s.require_paths = ["lib"]

  s.add_dependency "virtus", "~> 1.0.5"
  s.add_dependency "activesupport", "~> 4.2.0"

  s.add_development_dependency "rspec",         "~> 3.4"
  s.add_development_dependency "awesome_print", "~> 1.6"
  s.add_development_dependency "pry",           "~> 0.10.3"
end
