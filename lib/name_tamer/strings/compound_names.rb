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
      'Bodley Scott',
      'Bonham Carter',
      'Bruce Lockhart',
      'Child Villiers',
      'Conan Doyle',
      'Cotta Ramusino',
      'Cowden Clarke',
      'Duncan Smith',
      'Gavan Duffy',
      'Holmes a Court',
      'Holmes à Court',
      'Jones Parry',
      'Kamerlingh Onnes',
      'Lane Fox',
      'Llewelyn Davies',
      'Lloyd George',
      'Lloyd Webber',
      'Mahdavi Damghani',
      'Maynard Smith',
      'Montagu Douglas Scott',
      'Pitt Rivers',
      'Prinsen Geerligs',
      'Scott Moncrieff',
      'Scott Thomas',
      'Sebag Montefiore',
      'Strang Steel',
      'Targioni Tozzetti',
      'Tidjani Serpos',
      'Toulmin Smith',
      'Ulland Andersen',
      'Vaughan Williams',
      'Vicat Cole',
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
