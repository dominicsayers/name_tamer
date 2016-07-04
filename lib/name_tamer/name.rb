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
      ct_as_sym = new_contact_type.to_sym

      unless @contact_type.nil? || @contact_type == ct_as_sym
        puts "Changing contact type of #{@name} from #{@contact_type} to #{new_contact_type}"
      end

      @contact_type = ct_as_sym
    end

    # These lines aren't used and aren't covered by specs
    #   def name=(new_name)
    #     initialize new_name, :contact_type => @contact_type
    #   end
    #
    #   def to_hash
    #     {
    #       name:         name,
    #       nice_name:    nice_name,
    #       simple_name:  simple_name,
    #       slug:         slug,
    #       contact_type: contact_type,
    #       last_name:    last_name,
    #       remainder:    remainder,
    #       adfix_found:  adfix_found
    #     }
    #   end

    private

    #--------------------------------------------------------
    # Tidy up the name we've received
    #--------------------------------------------------------

    def unescape
      @tidy_name.ensure_safe!.safe_unescape!.unescape_html!
    end

    def remove_zero_width
      @tidy_name.strip_unwanted!(ZERO_WIDTH_FILTER)
    end

    def tidy_spacing
      @tidy_name
        .space_around_comma!
        .strip_or_self!
        .whitespace_to!(ASCII_SPACE)
    end

    def fix_encoding_errors
      @tidy_name.fix_encoding_errors!
    end

    # Remove spaces from groups of initials
    def consolidate_initials
      @tidy_name
        .remove_spaces_from_initials!
        .ensure_space_after_initials!
    end

    # An adfix is either a prefix or a suffix
    def remove_adfixes
      if @last_name.nil?
        # Our name is still in one part, not two
        loop do
          @nice_name = remove_outermost_adfix(:suffix, @nice_name)
          break unless @adfix_found
        end

        loop do
          @nice_name = remove_outermost_adfix(:prefix, @nice_name)
          break unless @adfix_found
        end
      else
        # Our name is currently in two halves
        loop do
          @last_name = remove_outermost_adfix(:suffix, @last_name)
          break unless @adfix_found
        end

        loop do
          @remainder = remove_outermost_adfix(:prefix, @remainder)
          break unless @adfix_found
        end
      end
    end

    # Names in the form "Smith, John" need to be turned around to "John Smith"
    def fixup_last_name_first
      return if @contact_type == :organization

      parts = @nice_name.split ', '

      return unless parts.count == 2

      @last_name = parts[0] # Sometimes the last name alone is all caps and we can name-case it
      @remainder = parts[1]
    end

    # Sometimes we end up with mismatched braces after adfix stripping
    # e.g. "Ceres (Ceres Holdings LLC)" -> "Ceres (Ceres Holdings"
    def fixup_mismatched_braces
      left_brace_count = @nice_name.count '('
      right_brace_count = @nice_name.count ')'

      if left_brace_count > right_brace_count
        @nice_name += ')'
      elsif left_brace_count < right_brace_count
        @nice_name = '(' + @nice_name
      end
    end

    def name_wrangle
      # Fix case if all caps or all lowercase
      if @last_name.nil?
        name_wrangle_single_name
      else
        name_wrangle_split_name
      end
    end

    def name_wrangle_single_name
      lowercase = @nice_name.downcase
      uppercase = @nice_name.upcase
      fix_case = false

      if @contact_type == :organization
        fix_case = true if @nice_name == uppercase && @nice_name.length > 4
      elsif [uppercase, lowercase].include?(@nice_name)
        fix_case = true
      end

      @nice_name = name_case(lowercase) if fix_case
    end

    def name_wrangle_split_name
      # It's a person if we've split the name, so no organization logic here
      lowercase = @last_name.downcase
      uppercase = @last_name.upcase
      @last_name = name_case(lowercase) if [uppercase, lowercase].include?(@last_name)
      @nice_name = "#{@remainder} #{@last_name}"
    end

    # Conjoin compound names with non-breaking spaces
    def use_nonbreaking_spaces_in_compound_names
      @nice_name
        .nbsp_in_compound_name!
        .nbsp_in_name_modifier!
    end

    #--------------------------------------------------------
    # Make search name from nice name
    #--------------------------------------------------------

    # Remove initials from personal names unless they are the only identifier.
    # i.e. only remove initials if there's also a proper name there
    def remove_initials
      return unless @contact_type == :person

      temp_name = @simple_name.gsub(/\b([a-z](?:\.*\s+|\.))/i, '')

      # If the name still has at least one space we're OK
      @simple_name = temp_name if temp_name.include?(ASCII_SPACE)
    end

    def remove_middle_names
      return unless @contact_type == :person

      first_name, parts = find_first_usable_name(@simple_name.split)
      last_name, = find_last_usable_name(parts)

      return unless first_name || last_name

      separator = first_name && last_name ? ' ' : ''
      @simple_name = "#{first_name}#{separator}#{last_name}"
    end

    def find_first_usable_name(parts)
      part = nil

      parts.each_index do |i|
        part = parts[i]
        next if part.gsub(FILTER_COMPAT, '').empty?
        parts = parts.slice(i + 1, parts.length) # don't use "slice!"
        break
      end

      [part, parts]
    end

    def find_last_usable_name(parts)
      part = nil

      parts.reverse_each do |p|
        next if p.gsub(FILTER_COMPAT, '').empty?
        part = p
        break
      end

      part
    end

    def remove_periods_from_initials
      @simple_name.remove_periods_from_initials!
    end

    def standardize_words
      @simple_name.gsub!(/ *& */, ' and ') # replace ampersand characters with ' and '
      @simple_name.gsub!(/ *\+ */, ' plus ') # replace plus signs with ' plus '
      @simple_name.gsub!(/\bintl\b/i, 'International') # replace 'intl' with 'International'
      @simple_name.gsub!(/[־‐‑‒–—―−﹘﹣－]/, SLUG_DELIMITER) # Replace Unicode dashes with ASCII hyphen
      @simple_name.strip_unwanted!(/["“”™℠®©℗]/) # remove quotes and commercial decoration
    end

    #--------------------------------------------------------
    # Initialization and utilities
    #--------------------------------------------------------

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

    def contact_type_from(args)
      args_ct = args[:contact_type]
      return unless args_ct

      ct = args_ct.is_a?(Symbol) ? args_ct : args_ct.dup
      ct = ct.to_s unless [String, Symbol].include? ct.class
      ct.downcase! if ct.class == String
      ct = ct.to_sym
      ct = nil unless [:person, :organization].include? ct

      ct
    end

    # If we don't know the contact type, what's our best guess?
    def contact_type_best_effort
      if @contact_type
        @contact_type
      else
        # If it's just one word we'll assume organization.
        # If more then we'll assume a person
        @name.include?(ASCII_SPACE) ? :person : :organization
      end
    end

    # We pass to this routine either prefixes or suffixes
    def remove_outermost_adfix(adfix_type, name_part)
      ct, parts = find_contact_type_and_parts(ADFIX_PATTERNS[adfix_type], name_part)

      return name_part unless @adfix_found

      # If we've found a diagnostic adfix then set the contact type
      self.contact_type = ct

      # The remainder of the name will be in parts[0] or parts[2] depending
      # on whether this is a prefix or a suffix.
      # We'll also remove any trailing commas we've exposed.
      (parts[0] + parts[2]).gsub(/\s*,\s*$/, '')
    end

    def find_contact_type_and_parts(adfixes, name_part)
      ct = contact_type_best_effort
      parts = name_part.partition adfixes[ct]
      @adfix_found = !parts[1].empty?

      return [ct, parts] if @contact_type || @adfix_found

      # If the contact type is indeterminate and we didn't find a diagnostic adfix
      # for a person then try again for an organization
      ct = :organization
      parts = name_part.partition adfixes[ct]
      @adfix_found = !parts[1].empty?

      [ct, parts]
    end

    # Original Version of NameCase:
    # Copyright (c) Mark Summerfield 1998-2008. All Rights Reserved
    # This module may be used/distributed/modified under the same terms as Perl itself
    # http://dev.perl.org/licenses/ (GPL)
    #
    # Ruby Version:
    # Copyright (c) Aaron Patterson 2006
    # NameCase is distributed under the GPL license.
    #
    # Substantially modified for Xendata
    # Improved in several areas, also now adds non-breaking spaces for
    # compound names like "van der Pump"
    def name_case(lowercase)
      n = lowercase.dup # We assume the name is passed already downcased

      n
        .upcase_first_letter!
        .downcase_after_apostrophe!
        .fix_mac!
        .fix_ff!
        .fix_name_modifiers!
        .upcase_initials!
    end
  end

  # Useful method for iterating through the words in the name
  def each_word(&block)
    @words ||= slug.split(SLUG_DELIMITER)
    @words.each(&block)
  end
end
