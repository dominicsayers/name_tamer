# frozen_string_literal: true

require 'simplecov'

unless ENV['NO_SIMPLECOV']
  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
    minimum_coverage line: 100, branch: 100
  end
end

require 'name_tamer'
require 'yaml'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
