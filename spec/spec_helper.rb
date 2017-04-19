unless ENV['NO_SIMPLECOV']
  require 'simplecov'
  require 'coveralls'

  SimpleCov.start { add_filter '/spec/' }
  Coveralls.wear! if ENV['COVERALLS_REPO_TOKEN']
end

require 'name_tamer'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
