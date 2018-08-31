$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "scavenger_hunt/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scavenger_hunt"
  s.version     = ScavengerHunt::VERSION
  s.authors     = ["Flip Sasser"]
  s.email       = ["flip.sasser@gmail.com"]
  s.homepage    = "https://github.com/coyote-team/coyote"
  s.summary     = ""
  s.description = ""
  s.license     = "UNLICENSED"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency "slim-rails", "~> 3.1.3"

  s.add_development_dependency "sqlite3"
end
