# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'htph/version'

Gem::Specification.new do |spec|
  spec.name          = "htph"
  spec.version       = HTPH::VERSION
  spec.authors       = ["Martin Warin"]
  spec.email         = ["mwarin@umich.edu"]
  spec.description   = "This gem contains modules written to deal with the HathiTrust Print Holdings database."
  spec.summary       = "Ceci n'est pas un summary"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "ext"]

  spec.add_dependency 'jdbc-helper', "0.8.0"
  spec.add_dependency 'dotenv-rails', '~> 2.0', '>= 2.0.2'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
