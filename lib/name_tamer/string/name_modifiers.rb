# frozen_string_literal: true

class String
  # Fixes for name modifiers followed by space
  # Also replaces spaces with non-breaking spaces
  # Fixes for name modifiers followed by an apostrophe, e.g. d'Artagnan, Commedia dell'Arte
  def fix_name_modifiers!
    NAME_MODIFIERS.each do |modifier|
      gsub!(/((?:[[:space:]]|^)#{modifier})([[:space:]]+|-)/) do |_|
        "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2].tr(ASCII_SPACE, NONBREAKING_SPACE)}"
      end
    end

    fix_apostrophe_modifiers!
    self # Allows chaining
  end

  def fix_apostrophe_modifiers!
    %w[Dell D].each do |modifier|
      gsub!(/(.#{modifier}')(\w)/) { |_| "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2]}" }
    end

    self # Allows chaining
  end

  def nbsp_in_name_modifier!
    NAME_MODIFIERS.each do |modifier|
      gsub!(/([[:space:]]#{modifier})([[:space:]])/i) { |_| "#{Regexp.last_match[1]}#{NONBREAKING_SPACE}" }
    end

    self # Allows chaining
  end

  NAME_MODIFIERS = [
    'Al',
    'Ap',
    'Ben',
    'D[aeiou]',
    'D[ao]s',
    'De[lrn]',
    'Dell[ae]',
    'El',
    'L[eo]',
    'La',
    'Of',
    'San',
    'St[\.]?',
    'V[ao]n',
    'Zur',
  ].freeze
end
