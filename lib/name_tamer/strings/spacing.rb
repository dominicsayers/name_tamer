# frozen_string_literal: true

module NameTamer
  module Strings
    extend self

    # Ensure commas have exactly one space after them
    def space_around_comma(string)
      string.gsub(/[[:space:]]*,[[:space:]]*/, ', ')
    end

    def remove_spaces_from_initials(string)
      string.gsub(/\b([a-z])(\.)* \b(?![a-z0-9'À-ÿ]{2,})/i) do
        "#{Regexp.last_match[1]}#{Regexp.last_match[2]}"
      end
    end

    def ensure_space_after_initials(string)
      string.gsub(/\b([a-z]\.)(?=[a-z0-9]{2,})/i) { "#{Regexp.last_match[1]} " }
    end
  end
end
