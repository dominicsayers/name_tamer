# frozen_string_literal: true

require_relative 'string/approximations'
require_relative 'string/bad_encoding'
require_relative 'string/capitalization'
require_relative 'string/colors'
require_relative 'string/compound_names'
require_relative 'string/name_modifiers'
require_relative 'string/spacing'
require_relative 'string/utilities'

class String
  unless respond_to? :presence
    def presence
      self unless empty?
    end
  end

  def strip_or_self!
    strip! || self
  end

  # Change any whitespace into our separator character
  def whitespace_to!(separator)
    substitute!(/[[:space:]]+/, separator)
  end

  # Change some characters embedded in words to our separator character
  # e.g. example.com -> example-com
  def invalid_chars_to!(separator)
    substitute!(%r{(?<![[:space:]])[./](?![[:space:]])}, separator)
  end

  # Remove HTML entities
  def unescape_html!
    replace CGI.unescapeHTML self
  end

  # Make sure separators are not where they shouldn't be
  def fix_separators!(separator)
    return self if separator.nil? || separator.empty?

    r = Regexp.escape(separator)

    # No more than one of the separator in a row.
    substitute!(/#{r}{2,}/, separator)

    # Remove leading/trailing separator.
    substitute!(/^#{r}|#{r}$/i, '')
  end

  def remove_periods_from_initials!
    gsub!(/\b([a-z])\./i) { |_| Regexp.last_match[1] } || self
  end
end
