lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'name_tamer/version'

Gem::Specification.new do |spec|
  spec.name          = 'name-tamer'
  spec.version       = NameTamer::VERSION
  spec.authors       = ['Xenapto']
  spec.email         = ['developers@xenapto.com']
  spec.description   = %q{Useful methods for taming names}
  spec.summary       = %q{Example: NameTamer['Mr. John Q. Smith III, MD'].simple_name # => John Smith}
  spec.homepage      = 'https://github.com/Xenapto/name-tamer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|coverage)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 2'
  spec.add_development_dependency 'gem-release', '~> 0'
  spec.add_development_dependency 'simplecov', '~> 0.7.1' # https://github.com/colszowka/simplecov/issues/281
  spec.add_development_dependency 'coveralls', '~> 0'
end
