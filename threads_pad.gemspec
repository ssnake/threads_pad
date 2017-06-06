$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "threads_pad/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "threads_pad"
  s.version     = ThreadsPad::VERSION
  s.authors     = ["Max Nedelchev"]
  s.email       = ["max@snakelab.cc"]
  s.homepage    = "https://github.com/ssnake/threads_pad"
  s.summary     = "A helpful tool for paralleling and asynchronous processing for Rails"
  s.description = "A helpful tool for paralleling and asynchronous processing for Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.0.2"

  #s.add_development_dependency "sqlite3"
end
