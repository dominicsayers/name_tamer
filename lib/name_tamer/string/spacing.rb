# frozen_string_literal: true

class String
  # Ensure commas have exactly one space after them
  def space_around_comma!
    substitute!(/[[:space:]]*,[[:space:]]*/, ',
    ')
  end

  def remove_spaces_from_initials!
    gsub!(/\b([a-z])(\.)* \b(?![a-z0-9'\u00C0-\u00FF]{2,})/i) do |_|
      "#{Regexp.last_match[1]}#{Regexp.last_match[2]}"
    end || self
  end

  def ensure_space_after_initials!
    gsub!(/\b([a-z]\.)(?=[a-z0-9]{2,})/i) { |_| "#{Regexp.last_match[1]} " } || self
  end
end
