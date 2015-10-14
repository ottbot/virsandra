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
  gem.homepage      = "https://github.com/ottbot/virsandra"

  gem.licenses      = ["MIT"]
  gem.files         =  Dir["{lib,vendor}/**/*"] + ["Rakefile", "README.md"]
  gem.test_files    = Dir["{spec}/**/*"]

  gem.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  gem.require_paths = ["lib"]

  gem.add_dependency "virtus", "~> 0.5"
  gem.add_dependency "cql-rb", "~> 1.2"
  gem.add_dependency "snappy", "~> 0.0.10"

  gem.add_development_dependency "rake", "~>10.0.4"
  gem.add_development_dependency "rspec", "~>2.13.0"
  gem.add_development_dependency "simplecov", "~>0.7.1"
  gem.add_development_dependency "simple_uuid", "~> 0.3.0"
end
