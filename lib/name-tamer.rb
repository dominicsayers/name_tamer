# encoding: utf-8
require 'string_extras'

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

class NameTamer
  attr_reader :name

  class << self
    def [](name, args = {})
      new name, args
    end

    # Make a slug from a string
    def parameterize(string, args = {})
      sep     = args[:sep]      || SLUG_DELIMITER
      rfc3987 = args[:rfc3987]  || false
      filter  = args[:filter]   || (rfc3987 ? FILTER_RFC3987 : FILTER_COMPAT)

      new_string = string.dup

      new_string
        .whitespace_to!(sep)
        .invalid_chars_to!(sep)
        .strip_unwanted!(filter)
        .fix_separators!(sep)
        .approximate_latin_chars!

      # Have we got anything left?
      new_string = '_' if new_string.empty?

      # downcase any latin characters
      new_string.downcase
    end
  end

  def tidy_name
    unless @tidy_name
      @tidy_name = name.dup # Start with the name we've received

      unescape              # Unescape percent-encoded characters and fix UTF-8 encoding
      remove_zero_width     # remove zero-width characters
      tidy_spacing          # " John   Smith " -> "John Smith"
      fix_encoding_errors   # "Ren\u00c3\u00a9 Descartes" -> "Ren\u00e9 Descartes"
      consolidate_initials  # "I. B. M." -> "I.B.M."
    end

    @tidy_name
  end

  def nice_name
    unless @nice_name
      @nice_name = tidy_name.dup      # Start with the tidied name

      remove_adfixes                  # prefixes and suffixes: "Smith, John, Jr." -> "Smith, John"
      fixup_last_name_first           # "Smith, John" -> "John Smith"
      fixup_mismatched_braces         # "Ceres (AZ" -> "Ceres (AZ)"
      remove_adfixes                  # prefixes and suffixes: "Mr John Smith Jr." -> "John Smith"
      name_wrangle                    # proper name case and non-breaking spaces
      use_nonbreaking_spaces_in_compound_names
    end

    @nice_name
  end

  def simple_name
    unless @simple_name
      @simple_name = nice_name.dup    # Start with nice name

      remove_initials               # "John Q. Doe" -> "John Doe"
      remove_middle_names           # "Philip Seymour Hoffman" -> "Philip Hoffman"
      remove_periods_from_initials  # "J.P.R. Williams" -> "JPR Williams"
      standardize_words             # "B&Q Intl" -> "B and Q International"

      @simple_name.whitespace_to!(ASCII_SPACE)
    end

    @simple_name
  end

  def slug
    @slug ||= NameTamer.parameterize simple_name.dup # "John Doe" -> "john-doe"
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
    @tidy_name.ensure_safe!.safe_unescape!
  end

  def remove_zero_width
    @tidy_name.strip_unwanted!(ZERO_WIDTH_FILTER)
  end

  def tidy_spacing
    @tidy_name
      .space_after_comma!
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

    @last_name    = parts[0] # Sometimes the last name alone is all caps and we can name-case it
    @remainder    = parts[1]
  end

  # Sometimes we end up with mismatched braces after adfix stripping
  # e.g. "Ceres (Ceres Holdings LLC)" -> "Ceres (Ceres Holdings"
  def fixup_mismatched_braces
    left_brace_count  = @nice_name.count '('
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
      lowercase = @nice_name.downcase
      uppercase = @nice_name.upcase
      fix_case = false

      if @contact_type == :organization
        fix_case = true if @nice_name == uppercase && @nice_name.length > 4
      else
        fix_case = true if [uppercase, lowercase].include?(@nice_name)
      end

      @nice_name  = name_case(lowercase) if fix_case
    else
      # It's a person if we've split the name, so no organization logic here
      lowercase = @last_name.downcase
      uppercase = @last_name.upcase
      @last_name  = name_case(lowercase) if [uppercase, lowercase].include?(@last_name)
      @nice_name  = "#{@remainder} #{@last_name}"
    end
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

    parts       = @simple_name.split
    first_name  = nil
    last_name   = nil

    # Find first usable name
    parts.each_index do |i|
      part = parts[i]
      next if part.gsub(FILTER_COMPAT, '').empty?
      first_name  = part
      parts       = parts.slice(i + 1, parts.length) # don't use "slice!"
      break
    end

    # Find last usable name
    parts.reverse_each do |part|
      next if part.gsub(FILTER_COMPAT, '').empty?
      last_name = part
      break
    end

    return unless first_name || last_name

    separator     = first_name && last_name ? ' ' : ''
    @simple_name  = "#{first_name}#{separator}#{last_name}"
  end

  def remove_periods_from_initials
    @simple_name.remove_periods_from_initials!
  end

  def standardize_words
    @simple_name.gsub!(/ *& */, ' and ')                 # replace ampersand characters with ' and '
    @simple_name.gsub!(/ *\+ */, ' plus ')               # replace plus signs with ' plus '
    @simple_name.gsub!(/\bintl\b/i, 'International')     # replace 'intl' with 'International'
    @simple_name.gsub!(/[־‐‑‒–—―−﹘﹣－]/, SLUG_DELIMITER) # Replace Unicode dashes with ASCII hyphen
    @simple_name.strip_unwanted!(/["“”™℠®©℗]/)           # remove quotes and commercial decoration
  end

  #--------------------------------------------------------
  # Initialization and utilities
  #--------------------------------------------------------

  def initialize(new_name, args = {})
    @name = new_name || ''

    if args[:contact_type]
      ct = args[:contact_type]
      ct = ct.to_s unless [String, Symbol].include? ct.class
      ct.downcase! if ct.class == String
      ct = ct.to_sym
      ct = nil unless [:person, :organization].include? ct
      @contact_type = ct
    end

    @tidy_name    = nil
    @nice_name    = nil
    @simple_name  = nil
    @slug         = nil

    @last_name    = nil
    @remainder    = nil

    @adfix_found  = false
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
    adfixes       = ADFIX_PATTERNS[adfix_type]
    ct            = contact_type_best_effort
    parts         = name_part.partition adfixes[ct]
    @adfix_found  = !parts[1].empty?

    # If the contact type is indeterminate and we didn't find a diagnostic adfix
    # for a person then try again for an organization
    if @contact_type.nil?
      unless @adfix_found
        ct            = :organization
        parts         = name_part.partition adfixes[ct]
        @adfix_found  = !parts[1].empty?
      end
    end

    if @adfix_found
      # If we've found a diagnostic adfix then set the contact type
      self.contact_type = ct

      # The remainder of the name will be in parts[0] or parts[2] depending
      # on whether this is a prefix or a suffix.
      # We'll also remove any trailing commas we've exposed.
      result = (parts[0] + parts[2]).gsub(/\s*,\s*$/, '')
    else
      result = name_part
    end

    result
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

  #--------------------------------------------------------
  # Constants
  #--------------------------------------------------------

  NONBREAKING_SPACE = "\u00a0"
  ASCII_SPACE       = "\u0020"
  ADFIX_JOINERS     = "[#{ASCII_SPACE}-]"
  SLUG_DELIMITER    = '-'

  ZERO_WIDTH_FILTER = /[\u200B\u200C\u200D\u2063\uFEFF]/

  # Constants for parameterizing Unicode strings for IRIs
  #
  # Allowed characters in an IRI segment are defined by RFC 3987
  # (https://tools.ietf.org/html/rfc3987#section-2.2) as follows:
  #
  #    isegment-nz-nc = 1*( iunreserved / pct-encoded / sub-delims
  #                         / "@" )
  #                   ; non-zero-length segment without any colon ":"
  #
  #    iunreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~" / ucschar
  #
  #    pct-encoded    = "%" HEXDIG HEXDIG
  #
  #    sub-delims     = "!" / "$" / "&" / "'" / "(" / ")"
  #                   / "*" / "+" / "," / ";" / "="
  #
  #    ucschar        = %xA0-D7FF / %xF900-FDCF / %xFDF0-FFEF
  #                   / %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
  #                   / %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
  #                   / %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
  #                   / %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
  #                   / %xD0000-DFFFD / %xE1000-EFFFD
  #
  # Note that we can't use Unicode code points above \uFFFF because of
  # regex limitations, so we'll ignore ucschar above that point.
  #
  # We're using the most restrictive segment definition (isegment-nz-nc)
  # to avoid any possible problems with the IRI that it one day might
  # get placed in.
  ALPHA           = 'A-Za-z'
  DIGIT           = '0-9'
  UCSCHAR         = '\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF'
  IUNRESERVED     = "#{ALPHA}#{DIGIT}\\-\\._~#{UCSCHAR}"
  SUBDELIMS       = '!$&\'\(\)\*+,;='
  ISEGMENT_NZ_NC  = "#{IUNRESERVED}#{SUBDELIMS}@" # pct-encoded not needed
  FILTER_RFC3987  = /[^#{ISEGMENT_NZ_NC}]/
  FILTER_COMPAT   = /[^#{ALPHA}#{DIGIT}\-_#{UCSCHAR}]/

  # These are the prefixes and suffixes we want to remove
  # If you add to the list, you can use spaces and dots where appropriate
  # Ensure any single letters are followed by a dot because we'll add one to the string
  # during processing, e.g. "y Cia." should be "y. Cia."
  ADFIXES = {
    prefix: {
      person: [
        'Baron', 'Baroness', 'Capt.', 'Captain', 'Col.', 'Colonel', 'Dame',
        'Doctor', 'Dr.', 'Judge', 'Justice', 'Lady', 'Lieut.', 'Lieutenant',
        'Lord', 'Madame', 'Major', 'Master', 'Matron', 'Messrs.', 'Mgr.',
        'Miss', 'Mister', 'Mlle.', 'Mme.', 'Mons.', 'Mr.', 'Mr. & Mrs.',
        'Mr. and Mrs.', 'Mrs.', 'Msgr.', 'Ms.', 'Prof.', 'Professor', 'Rev.',
        'Reverend', 'Sir', 'Sister', 'The Hon.', 'The Lady.', 'The Lord',
        'The Rt. Hon.'
      ],
      organization: [
        'Fa.', 'P.T.', 'P.T. Tbk.', 'U.D.'
      ],
      before: '\\A', after: ADFIX_JOINERS
    },
    suffix: {
      person: [
        'Chartered F.C.S.I.',
        'C.I.S.S.P.', 'T.M.I.E.T.', 'A.C.C.A.', 'C.I.T.P.', 'F.B.C.S.', 'F.C.C.A.', 'F.C.M.I.', 'F.I.E.T.', 'F.I.R.P.',
        'M.I.E.T.', 'B.Tech.',
        'Cantab.', 'D.Phil.', 'I.T.I.L. v3', 'B.Eng.', 'C.Eng.', 'M.Jur.', 'C.F.A.', 'D.B.E.',
        'D.D.S.', 'D.V.M.', 'Eng.D.', 'A.C.A.', 'C.T.A.', 'E.R.P.', 'F.C.A', 'F.P.C.', 'F.R.M.', 'M.B.A.', 'M.B.E.',
        'M.E.P.', 'M.Eng.', 'M.Jur.', 'M.S.P.', 'O.B.E.', 'P.M.C.', 'P.M.P.', 'P.S.P.', 'V.M.D.', 'B.Ed.', 'B.Sc.',
        'Ed.D.', 'Hons.', 'LL.B.',
        'LL.D.', 'LL.M.', 'M.Ed.', 'M.Sc.', 'Oxon.', 'Ph.D.', 'B.A.', 'Esq.', 'J.D.', 'K.C.', 'M.A.', 'M.D.', 'M.P.',
        'O.K.', 'P.A.', 'Q.C.', 'III', 'Jr.', 'Sr.', 'II', 'IV', 'I', 'V'
      ],
      organization: [
        'S. de R.L. de C.V.', 'S.A.P.I. de C.V.', 'y. Cía. S. en C.', 'Private Limited', 'S.M. Pte. Ltd.',
        'Cía. S. C. A.', 'y. Cía. S. C.', 'S.A. de C.V.', 'spol. s.r.o.', '(Pty.) Ltd.', '(Pvt.) Ltd.', 'A.D.S.I.Tz.',
        'S.p. z.o.o.', '(Pvt.)Ltd.', 'akc. spol.', 'Cía. Ltda.', 'E.B.V.B.A.', 'P. Limited', 'S. de R.L.', 'S.I.C.A.V.',
        'S.P.R.L.U.', 'А.Д.С.И.Ц.', '(P.) Ltd.', 'C. por A.', 'Comm.V.A.', 'Ltd. Şti.', 'Plc. Ltd.', 'Pte. Ltd.',
        'Pty. Ltd.', 'Pvt. Ltd.', 'Soc. Col.', 'A.M.B.A.', 'A.S.B.L.', 'A.V.E.E.', 'B.V.B.A.', 'B.V.I.O.', 'C.V.B.A.',
        'C.V.O.A.', 'E.E.I.G.', 'E.I.R.L.', 'E.O.O.D.', 'E.U.R.L.', 'F.M.B.A.', 'G.m.b.H.', 'Ges.b.R.', 'I.L.L.C.',
        'K.G.a.A.', 'L.L.L.P.', 'Ltd. Co.', 'Ltd. Co.', 'M.E.P.E.', 'n.y.r.t.', 'O.V.E.E.', 'P.E.E.C.', 'P.L.L.C.',
        'P.L.L.C.', 'S. en C.', 'S.a.p.a.', 'S.A.R.L.', 'S.à.R.L.', 'S.A.S.U.', 'S.C.e.I.', 'S.C.O.P.', 'S.C.p.A.',
        'S.C.R.I.', 'S.C.R.L.', 'S.M.B.A.', 'S.P.R.L.', 'Е.О.О.Д.', 'and Co.', 'Comm.V.', 'Limited', 'P. Ltd.',
        'Part.G.', 'Sh.p.k.', '&. Co.', '&. Cie.', 'C.X.A.', 'd.n.o.', 'd.o.o.', 'E.A.D.', 'e.h.f.', 'E.P.E.', 'E.S.V.',
        'F.C.P.',
        'F.I.E.', 'G.b.R.', 'G.I.E.', 'G.M.K.', 'G.S.K.', 'H.U.F.', 'K.D.A.', 'k.f.t.', 'k.h.t.', 'k.k.t.', 'L.L.C.',
        'L.L.P.', 'o.h.f.', 'O.H.G.', 'O.O.D.', 'O.y.j.', 'p.l.c.', 'P.S.U.', 'S.A.E.', 'S.A.S.', 'S.C.A.', 'S.C.E.',
        'S.C.S.', 'S.E.M.', 'S.E.P.', 's.e.s.', 'S.G.R.', 'S.N.C.', 'S.p.A.', 'S.P.E.', 'S.R.L.', 's.r.o.', 'Unltd.',
        'V.O.F.', 'V.o.G.', 'v.o.s.', 'V.Z.W.', 'z.r.t.', 'А.А.Т.', 'Е.А.Д.', 'З.А.Т.', 'К.Д.А.', 'О.О.Д.', 'Т.А.А.',
        '股份有限公司', 'Ap.S.', 'Corp.', 'ltda.', 'Sh.A.', 'st.G.', 'Ultd.', 'a.b.', 'A.D.', 'A.E.', 'A.G.', 'A.S.',
        'A.Ş.', 'A.y.', 'B.M.', 'b.t.', 'B.V.', 'C.A.', 'C.V.', 'd.d.', 'e.c.', 'E.E.', 'e.G.', 'E.I.', 'E.P.', 'E.T.',
        'E.U.', 'e.v.', 'G.K.', 'G.P.', 'h.f.', 'Inc.', 'K.D.', 'K.G.', 'K.K.', 'k.s.', 'k.v.', 'K.y.', 'L.C.', 'L.P.',
        'Ltd.', 'N.K.', 'N.L.', 'N.V.', 'O.E.', 'O.G.', 'O.Ü.', 'O.y.', 'P.C.', 'p.l.', 'Pty.', 'PUP.', 'Pvt.', 'r.t.',
        'S.A.', 'S.D.', 'S.E.', 's.f.', 'S.L.', 'S.P.', 'S.s.', 'T.K.', 'T.Ü.', 'U.Ü.', 'Y.K.', 'А.Д.', 'І.П.', 'К.Д.',
        'ПУП.', 'С.Д.', 'בע"מ', '任意組合', '匿名組合', '合同会社', '合名会社', '合資会社', '有限会社', '有限公司', '株式会社',
        'A/S', 'G/S', 'I/S', 'K/S', 'P/S', 'S/A'
      ],
      before: ADFIX_JOINERS, after: '\\z'
    }
  }

  ADFIX_PATTERNS = {}

  [:prefix, :suffix].each do |adfix_type|
    patterns  = {}
    adfix     = ADFIXES[adfix_type]

    [:person, :organization].each do |ct|
      with_optional_spaces    = adfix[ct].map { |p| p.gsub(ASCII_SPACE, ' *') }
      pattern_string          = with_optional_spaces.join('|').gsub('.', '\.*')
      patterns[ct]  = /#{adfix[:before]}\(*(?:#{pattern_string})\)*#{adfix[:after]}/i
    end

    ADFIX_PATTERNS[adfix_type] = patterns
  end
end
