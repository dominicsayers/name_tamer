# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'name_tamer/version'

Gem::Specification.new do |spec|
  spec.name = 'name_tamer'
  spec.version = NameTamer::VERSION
  spec.authors = ['Dominic Sayers']
  spec.email = ['dominic@sayers.cc']
  spec.description = 'Useful methods for taming names'
  spec.summary = "Example: NameTamer['Mr. John Q. Smith III, MD'].simple_name # => John Smith"
  spec.homepage = 'https://github.com/dominicsayers/name_tamer'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR).reject { |file| file =~ %r{^(bin|spec)/} }
  spec.test_files = spec.files.grep(%r{^(test|spec|features|coverage)/})
  spec.require_paths = ['lib']
end
