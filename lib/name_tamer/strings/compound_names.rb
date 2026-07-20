# frozen_string_literal: true

module NameTamer
  module Strings
    extend self

    # Fix known last names that have spaces (not hyphens!)
    def nbsp_in_compound_name(string)
      COMPOUND_NAMES.reduce(string) do |name, compound_name|
        name.gsub(compound_name, compound_name.tr(ASCII_SPACE, NONBREAKING_SPACE))
      end
    end

    COMPOUND_NAMES = [
      # Known families with a space in their surname
      'Baron Cohen',
      'Bonham Carter',
      'Holmes a Court',
      'Holmes à Court',
      'Lane Fox',
      'Lloyd Webber',
      'Pitt Rivers',
      'Sebag Montefiore',
      'Strang Steel',
      'Wedgwood Benn',
      'Wingfield Digby',
      # Sometimes companies appear as people
      'Corporation Company',
      'Corporation System',
      'Incorporations Limited',
      'Service Company',
    ].freeze
  end
end
