# encoding: utf-8
require 'cgi'
require 'name_tamer/string'
require 'name_tamer/constants'

module NameTamer
  autoload :Name, 'name_tamer/name'

  class << self
    def [](name, args = {})
      NameTamer::Name.new name, args
    end

    # Make a slug from a string
    def parameterize(string, args = {})
      sep = args[:sep] || SLUG_DELIMITER
      rfc3987 = args[:rfc3987] || false
      filter = args[:filter] || (rfc3987 ? FILTER_RFC3987 : FILTER_COMPAT)

      new_string = string.dup

      new_string
        .whitespace_to!(sep)
        .invalid_chars_to!(sep)
        .strip_unwanted!(filter)
        .fix_separators!(sep)
        .approximate_latin_chars!

      # Have we got anything left?
      new_string = '_' if new_string.empty?

      # downcase any latin characters
      new_string.downcase
    end
  end
end
