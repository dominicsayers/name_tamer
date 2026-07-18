# frozen_string_literal: true

require_relative 'lib/name_tamer/version'

Gem::Specification.new do |spec|
  spec.name = 'name_tamer'
  spec.version = NameTamer::VERSION
  spec.authors = ['Dominic Sayers']
  spec.email = ['dominic@sayers.cc']
  spec.description = 'Useful methods for taming names'
  spec.summary = "Example: NameTamer['Mr. John Q. Smith III, MD'].simple_name # => John Smith"
  spec.homepage = 'https://github.com/dominicsayers/name_tamer'
  spec.license = 'MIT'

  spec.metadata = {
    'homepage_uri' => 'https://github.com/dominicsayers/name_tamer',
    'source_code_uri' => 'https://github.com/dominicsayers/name_tamer',
    'changelog_uri' => 'https://github.com/dominicsayers/name_tamer/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/dominicsayers/name_tamer/issues',
    'rubygems_mfa_required' => 'true',
  }

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.3'
end
