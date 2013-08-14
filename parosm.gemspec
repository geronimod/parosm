# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parosm/version'

Gem::Specification.new do |gem|
  gem.name          = "parosm"
  gem.version       = Parosm::VERSION
  gem.authors       = ["Geronimo Diaz"]
  gem.email         = ["geronimod@gmail.com"]
  gem.description   = %q{ OSM Parser }
  gem.summary       = %q{ Simple ruby OSM data parser }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.rubyforge_project = "parosm"
  
  gem.add_dependency "nokogiri"
  gem.add_dependency "pg"
  gem.add_development_dependency "rspec"

end
