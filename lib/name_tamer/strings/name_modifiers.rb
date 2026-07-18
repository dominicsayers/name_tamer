# frozen_string_literal: true

module NameTamer
  module Strings
    module_function

    # Fixes for name modifiers followed by space
    # Also replaces spaces with non-breaking spaces
    # Fixes for name modifiers followed by an apostrophe,
    # e.g. d'Artagnan, Commedia dell'Arte
    def fix_name_modifiers(string)
      fixed = NAME_MODIFIERS.reduce(string) do |name, modifier|
        name.gsub(/((?:[[:space:]]|^)#{modifier})([[:space:]]+|-)/) do
          "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2].tr(ASCII_SPACE, NONBREAKING_SPACE)}"
        end
      end

      fix_apostrophe_modifiers(fixed)
    end

    def fix_apostrophe_modifiers(string)
      %w[Dell D].reduce(string) do |name, modifier|
        name.gsub(/(.#{modifier}')(\w)/) { "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2]}" }
      end
    end

    def nbsp_in_name_modifier(string)
      NAME_MODIFIERS.reduce(string) do |name, modifier|
        name.gsub(/([[:space:]]#{modifier})([[:space:]])/i) { "#{Regexp.last_match[1]}#{NONBREAKING_SPACE}" }
      end
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
end
