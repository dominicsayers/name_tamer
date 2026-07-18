# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :development, :test do
  gem 'debug'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end

group :development do
  gem 'bundler'
  gem 'csv' # used by doc/maintenance.rake; no longer a default gem in Ruby 3.4
  gem 'rake'
end

group :test do
  gem 'fuubar'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'simplecov', '~> 1.0'
end
