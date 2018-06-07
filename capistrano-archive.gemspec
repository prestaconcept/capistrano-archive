# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/archive/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-archive"
  spec.version       = Capistrano::Archive::VERSION
  spec.authors       = ['David Gaussinel']
  spec.email         = ['dgaussinel@prestaconcept.net']
  spec.description   = 'Transfer archive release strategy for capistrano.'
  spec.summary       = 'Transfer archive release strategy for capistrano.'
  spec.homepage      = 'https://github.com/prestaconcept/capistrano-archive'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/) 
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '>= 3.7.0', '< 4.0.0'
end
