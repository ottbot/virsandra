# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virsandra/version'

Gem::Specification.new do |gem|
  gem.name          = "virsandra"
  gem.version       = Virsandra::VERSION
  gem.authors       = ["Robert Crim"]
  gem.email         = ["rob@servermilk.com"]
  gem.description   = %q{Cassandra CQL3 persistence for Virtus extended classes}
  gem.summary       = %q{Easily store models defined with Virtus in Cassandra using CQL3}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  #gem.add_dependency "cassandra-cql", #WHEN IT SUPPORTS CQL3
  gem.add_dependency "virtus", ">= 0.5.4"
  gem.add_dependency "cql-rb", ">= 1.0.2"
  gem.add_dependency "simple_uuid", ">= 0.3.0"

  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "rspec", ">= 2.10.0"
  gem.add_development_dependency "simplecov"
end
