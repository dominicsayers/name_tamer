# frozen_string_literal: true

module NameTamer
  # Pure string transformations used throughout the gem. Every method
  # takes a string and returns a new string; arguments are never mutated.
  module Strings
    extend self

    def presence(string)
      string unless string.empty?
    end

    # Change any whitespace into our separator character
    def whitespace_to(string, separator)
      string.gsub(/[[:space:]]+/, separator)
    end

    # Change some characters embedded in words to our separator character
    # e.g. example.com -> example-com
    def invalid_chars_to(string, separator)
      string.gsub(%r{(?<![[:space:]])[./](?![[:space:]])}, separator)
    end

    # Remove HTML entities
    def unescape_html(string)
      CGI.unescapeHTML string
    end

    # Make sure separators are not where they shouldn't be
    def fix_separators(string, separator)
      return string if separator.nil? || separator.empty?

      r = Regexp.escape(separator)

      # No more than one separator in a row, no leading or trailing separator
      string.gsub(/#{r}{2,}/, separator).gsub(/^#{r}|#{r}$/i, '')
    end

    def remove_periods_from_initials(string)
      string.gsub(/\b([a-z])\./i) { Regexp.last_match[1] }
    end

    # Strip unwanted characters out completely
    def strip_unwanted(string, filter)
      string.gsub(filter, '')
    end

    # Unescape percent-encoded characters
    # This might introduce UTF-8 invalid byte sequence
    # so we take precautions
    def safe_unescape(string)
      unescaped = CGI.unescape(string.gsub('+', '%2B'))
      return string if string == unescaped

      ensure_safe(unescaped)
    end

    def ensure_safe(string)
      string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end
  end
end
