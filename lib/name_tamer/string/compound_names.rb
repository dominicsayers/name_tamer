# frozen_string_literal: true

class String
  # Fix known last names that have spaces (not hyphens!)
  def nbsp_in_compound_name!
    COMPOUND_NAMES.each do |compound_name|
      substitute!(compound_name, compound_name.tr(ASCII_SPACE, NONBREAKING_SPACE))
    end

    self # Allows chaining
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
