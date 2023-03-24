# frozen_string_literal: true

class String
  # Strip illegal characters out completely
  def strip_unwanted!(filter)
    substitute!(filter, '')
  end

  # Unescape percent-encoded characters
  # This might introduce UTF-8 invalid byte sequence
  # so we take precautions
  def safe_unescape!
    string = CGI.unescape(gsub('+', '%2B'))
    return self if self == string

    replace string
    ensure_safe!
  end

  def ensure_safe!
    encode!('UTF-8', invalid: :replace, undef: :replace, replace: '') # Doesn't fully work in Ruby 2.0
  end

  def substitute!(pattern, replacement)
    gsub!(pattern, replacement) || self
  end

  NONBREAKING_SPACE = "\u00a0"
  ASCII_SPACE = ' '
end
