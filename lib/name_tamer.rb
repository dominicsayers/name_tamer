# encoding: utf-8

require 'cgi'
require 'name_tamer/string'
require 'name_tamer/array'
require 'name_tamer/constants'

module NameTamer
  autoload :Name, 'name_tamer/name'
  autoload :Text, 'name_tamer/text'

  class << self
    def [](name, args = {})
      NameTamer::Name.new name, args
    end

    # Make a slug from a string
    def parameterize(string, args = {})
      NameTamer::Text.new(string, args).parameterize
    end
  end
end
