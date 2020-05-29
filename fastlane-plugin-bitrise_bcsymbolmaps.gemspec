# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/bitrise_bcsymbolmaps/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-bitrise_bcsymbolmaps'
  spec.version       = Fastlane::BitriseBcsymbolmaps::VERSION
  spec.author        = 'Oleksandr Skrypnyk'
  spec.email         = 'olexandr.skrypnyk@me.com'

  spec.summary       = 'Download BCSymbolMaps from Bitrise'
  spec.homepage      = "https://github.com/sxua/fastlane-plugin-bitrise_bcsymbolmaps"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('fastlane', '>= 2.148.0')
end
