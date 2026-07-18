# frozen_string_literal: true

unless ENV['NO_SIMPLECOV']
  require 'simplecov'

  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
  end
end

require 'name_tamer'
require 'yaml'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
