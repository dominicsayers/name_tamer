# frozen_string_literal: true

require_relative 'name/private_methods_nice_name'
require_relative 'name/private_methods_simple_name'
require_relative 'name/utilities'

module NameTamer
  class Name
    # References:
    # http://www.w3.org/International/questions/qa-personal-names
    # https://github.com/berkmancenter/namae
    # https://github.com/mericson/people
    # http://en.wikipedia.org/wiki/Types_of_business_entity
    # http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(USA)
    # http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(United_Kingdom)
    # http://en.wikipedia.org/wiki/Nobiliary_particle
    # http://en.wikipedia.org/wiki/Spanish_naming_customs
    # http://linguistlist.org/pubs/tocs/JournalUnifiedStyleSheet2007.pdf [PDF]
    attr_reader :name

    def tidy_name
      unless @tidy_name
        @tidy_name = name.dup # Start with the name we've received

        unescape # Unescape percent-encoded characters and fix UTF-8 encoding
        remove_zero_width # remove zero-width characters
        tidy_spacing # " John   Smith " -> "John Smith"
        fix_encoding_errors # "Ren\u00c3\u00a9 Descartes" -> "Ren\u00e9 Descartes"
        consolidate_initials # "I. B. M." -> "I.B.M."
      end

      @tidy_name
    end

    def nice_name
      unless @nice_name
        @nice_name = tidy_name.dup # Start with the tidied name

        remove_adfixes # prefixes and suffixes: "Smith, John, Jr." -> "Smith, John"
        fixup_last_name_first # "Smith, John" -> "John Smith"
        fixup_mismatched_braces # "Ceres (AZ" -> "Ceres (AZ)"
        remove_adfixes # prefixes and suffixes: "Mr John Smith Jr." -> "John Smith"
        name_wrangle # proper name case and non-breaking spaces
        use_nonbreaking_spaces_in_compound_names
      end

      @nice_name
    end

    def simple_name
      unless @simple_name
        @simple_name = nice_name.dup # Start with nice name

        remove_initials # "John Q. Doe" -> "John Doe"
        remove_middle_names # "Philip Seymour Hoffman" -> "Philip Hoffman"
        remove_periods_from_initials # "J.P.R. Williams" -> "JPR Williams"
        standardize_words # "B&Q Intl" -> "B and Q International"

        @simple_name.whitespace_to!(ASCII_SPACE)
      end

      @simple_name
    end

    def slug
      @slug ||= NameTamer.parameterize simple_name.dup # "John Doe" -> "john-doe"
    end

    def array
      @array ||= slug.split(SLUG_DELIMITER)
    end

    def contact_type
      nice_name # make sure we've done the bit which infers contact_type
      contact_type_best_effort
    end

    def contact_type=(new_contact_type)
      @contact_type = new_contact_type.to_sym
    end

    # Useful method for iterating through the words in the name
    def each_word(&block)
      @words ||= slug.split(SLUG_DELIMITER)
      @words.each(&block)
    end

    private

    include Name::PrivateMethodsNiceName
    include Name::PrivateMethodsSimpleName
    include Name::Utilities

    def initialize(new_name, args = {})
      @name = new_name || ''
      @contact_type = contact_type_from args

      @tidy_name = nil
      @nice_name = nil
      @simple_name = nil
      @slug = nil

      @last_name = nil
      @remainder = nil

      @adfix_found = false
    end
  end
end
