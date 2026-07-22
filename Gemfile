# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :development, :test do
  gem 'debug'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end

group :development do
  gem 'bundler'
  gem 'csv' # used by docs/maintenance.rake; no longer a default gem in Ruby 3.4
  gem 'rake'
end

group :test do
  gem 'rspec'
  gem 'simplecov', '~> 1.0'
end
