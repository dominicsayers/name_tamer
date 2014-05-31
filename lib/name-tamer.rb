# encoding: utf-8

# References:
# http://www.w3.org/International/questions/qa-personal-names
# https://github.com/berkmancenter/namae
# https://github.com/mericson
# http://en.wikipedia.org/wiki/Types_of_business_entity
# http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(USA)
# http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(United_Kingdom)
# http://en.wikipedia.org/wiki/Nobiliary_particle
# http://en.wikipedia.org/wiki/Spanish_naming_customs
# http://linguistlist.org/pubs/tocs/JournalUnifiedStyleSheet2007.pdf [PDF]

class NameTamer
  attr_reader :name, :contact_type

  class << self
    def [](name, args = {})
      new name, args
    end
  end

  def nice_name
    if @nice_name.nil?
      @nice_name = @name.dup          # Start with the name we've received

      tidy_spacing                    # " John   Smith " -> "John Smith"
      consolidate_initials            # "I. B. M." -> "I.B.M."
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
    if @simple_name.nil?
      @simple_name = nice_name.dup    # Start with nice name

      remove_initials                 # "John Q. Doe" -> "John Doe"
      remove_middle_names             # "Philip Seymour Hoffman" -> "Philip Hoffman"
      remove_dots_from_abbreviations  # "J.P.R. Williams" -> "JPR Williams"
      standardize_words               # "B&Q Intl" -> "B and Q International"

      @simple_name = ensure_whitespace_is_ascii_space @simple_name
    end

    @simple_name
  end

  def slug
    if @slug.nil?
      @slug = simple_name.dup         # Start with search name
      slugify                         # "John Doe" -> "john-doe"
    end

    @slug
  end

  def contact_type
    nice_name # make sure we've done the bit which infers contact_type
    contact_type_best_effort
  end

=begin These lines aren't used and aren't covered by specs
  def name=(new_name)
    initialize new_name, :contact_type => @contact_type
  end

  def contact_type=(new_contact_type)
    initialize @name, :contact_type => new_contact_type
  end

  def to_hash
    {
      name:         @name,
      nice_name:    @nice_name,
      simple_name:  @simple_name,
      slug:         @slug,
      contact_type: @contact_type,
      last_name:    @last_name,
      remainder:    @remainder,
      adfix_found:  @adfix_found
    }
  end
=end

  private

  #--------------------------------------------------------
  # Tidy up the name we've received
  #--------------------------------------------------------

  def tidy_spacing
    @nice_name.gsub!(/,\s*/, ', ') # Ensure commas have exactly one space after them
    @nice_name.strip!              # remove leading & trailing whitespace

    @nice_name = ensure_whitespace_is_ascii_space @nice_name
  end

  # Remove spaces from groups of initials
  def consolidate_initials
    @nice_name.gsub!(/\b([a-z])\.* (?=[a-z][\. ])/i) { |match| "#{$1}." }   # Remove spaces from initial groups
    @nice_name.gsub!(/\b([a-z](?:\.[a-z])+)\.?(?= )/i) { |match| "#{$1}." } # Ensure each group ends with a dot
  end

  # An adfix is either a prefix or a suffix
  def remove_adfixes
    if @last_name.nil?
      # Our name is still in one part, not two
      begin
        @nice_name = remove_outermost_adfix(:suffix, @nice_name)
      end while @adfix_found

      begin
        @nice_name = remove_outermost_adfix(:prefix, @nice_name)
      end while @adfix_found
    else
      # Our name is currently in two halves
      begin
        @last_name = remove_outermost_adfix(:suffix, @last_name)
      end while @adfix_found

      begin
        @remainder = remove_outermost_adfix(:prefix, @remainder)
      end while @adfix_found
    end
  end

  # Names in the form "Smith, John" need to be turned around to "John Smith"
  def fixup_last_name_first
    unless @contact_type == :organization
      parts = @nice_name.split ', '

      if parts.count == 2
        @last_name    = parts[0] # Sometimes the last name alone is all caps and we can name-case it
        @remainder    = parts[1]
      end
    end
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

      # Some companies like to be all lowercase so don't mess with them
      @nice_name  = name_case(lowercase) if @nice_name == uppercase || ( @nice_name == lowercase && @contact_type != :organization )
    else
      lowercase = @last_name.downcase
      uppercase = @last_name.upcase
      @last_name  = name_case(lowercase) if @last_name == uppercase || @last_name == lowercase

      @nice_name  = "#{@remainder} #{@last_name}"
    end
  end

  # Conjoin compound names with non-breaking spaces
  def use_nonbreaking_spaces_in_compound_names
    # Fix known last names that have spaces (not hyphens!)
    [
      'Lane Fox', 'Bonham Carter', 'Pitt Rivers', 'Lloyd Webber', 'Sebag Montefiore',
      'Holmes à Court', 'Holmes a Court', 'Baron Cohen',
      'Service Company', 'Corporation Company', 'Corporation System', 'Incorporations Limited'
    ].each do |compound_name|
      @nice_name.gsub!(compound_name, compound_name.tr(ASCII_SPACE, NONBREAKING_SPACE))
    end

    NAME_MODIFIERS.each do |modifier|
      @nice_name.gsub!(/([[:space:]]#{modifier})([[:space:]])/i) { |match| "#{$1}#{NONBREAKING_SPACE}" }
    end
  end

  #--------------------------------------------------------
  # Make search name from nice name
  #--------------------------------------------------------

  # Remove initials from personal names unless they are the only identifier.
  # i.e. only remove initials if there's also a proper name there
  def remove_initials
    if @contact_type == :person
      name = @simple_name.gsub(/\b([a-z](?:\.*\s+|\.))/i, '')

      # If the name still has at least one space we're OK
      @simple_name = name if name.include?(ASCII_SPACE)
    end
  end

  def remove_middle_names
    if @contact_type == :person
      parts = @simple_name.split
      @simple_name = "#{parts[0]} #{parts[-1]}" if parts.count > 2
    end
  end

  def remove_dots_from_abbreviations
    @simple_name.gsub!(/\b([a-z])\./i) { |match| $1 }
  end

  def standardize_words
    @simple_name.gsub!(/ *& */, ' and ')              # replace ampersand characters with ' and '
    @simple_name.gsub!(/ *\+ */, ' plus ')            # replace plus signs with ' plus '
    @simple_name.gsub!(/\bintl\b/i, 'International')  # replace 'intl' with 'International'
  end

  #--------------------------------------------------------
  # Make slug from search name
  #--------------------------------------------------------

  def slugify
    # Inflector::parameterize just gives up with non-latin characters so...
    #@slug = @slug.parameterize # Can't use this

    # Instead we'll do it ourselves
    @slug = parameterize @slug
  end

  #--------------------------------------------------------
  # Initialization and utilities
  #--------------------------------------------------------

  def initialize(name, args = {})
    @name         = name || ''
    @contact_type = args[:contact_type].to_sym unless args[:contact_type].nil?

    @nice_name    = nil
    @simple_name  = nil
    @slug         = nil

    @last_name    = nil
    @remainder    = nil

    @adfix_found  = false
  end

  def set_contact_type contact_type
    contact_type_sym = contact_type.to_sym
    puts "Changing contact type of #{@name} from #{@contact_type} to #{contact_type}".red unless @contact_type.nil? || @contact_type == contact_type_sym
    @contact_type = contact_type_sym
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

  def ensure_whitespace_is_ascii_space string
    string.gsub(/[[:space:]]+/, ASCII_SPACE) # /\s/ doesn't match Unicode whitespace in Ruby 1.9.3
  end

  # We pass to this routine either prefixes or suffixes
  def remove_outermost_adfix adfix_type, name_part
    adfixes       = ADFIX_PATTERNS[adfix_type]
    contact_type  = contact_type_best_effort
    parts         = name_part.partition adfixes[contact_type]
    @adfix_found  = !parts[1].empty?

    # If the contact type is indeterminate and we didn't find a diagnostic adfix
    # for a person then try again for an organization
    if @contact_type.nil?
      unless @adfix_found
        contact_type  = :organization
        parts         = name_part.partition adfixes[contact_type]
        @adfix_found  = !parts[1].empty?
      end
    end

    if @adfix_found
      # If we've found a diagnostic adfix then set the contact type
      set_contact_type contact_type

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
  def name_case lowercase
    name = lowercase # We assume the name is passed already downcased
    name.gsub!(/\b\w/) { |first| first.upcase }
    name.gsub!(/\'\w\b/) { |c| c.downcase } # Lowercase 's

    # Our list of terminal characters that indicate a non-celtic name used
    # to include o but we removed it because of MacMurdo.
    if name =~ /\bMac[A-Za-z]{2,}[^acizj]\b/ or name =~ /\bMc/
      name.gsub!(/\b(Ma?c)([A-Za-z]+)/) { |match| $1 + $2.capitalize }

      # Fix Mac exceptions
      [
        'MacEdo', 'MacEvicius', 'MacHado', 'MacHar', 'MacHin', 'MacHlin', 'MacIas', 'MacIulis', 'MacKie', 'MacKle',
        'MacKlin', 'MacKmin', 'MacKmurdo', 'MacQuarie', 'MacLise', 'MacKenzie'
      ].each { |mac_name| name.gsub!(/\b#{mac_name}/, mac_name.capitalize) }
    end

    # Fix ff wierdybonks
    [
      'Fforbes', 'Fforde', 'Ffinch', 'Ffrench', 'Ffoulkes'
    ].each { |ff_name| name.gsub!(ff_name,ff_name.downcase) }

    # Fixes for name modifiers followed by space
    # Also replaces spaces with non-breaking spaces
    NAME_MODIFIERS.each do |modifier|
      name.gsub!(/((?:[[:space:]]|^)#{modifier})(\s+|-)/) { |match| "#{$1.rstrip.downcase}#{$2.tr(ASCII_SPACE, NONBREAKING_SPACE)}" }
    end

    # Fixes for name modifiers followed by an apostrophe, e.g. d'Artagnan, Commedia dell'Arte
    ['Dell', 'D'].each do |modifier|
      name.gsub!(/(.#{modifier}')(\w)/) { |match| "#{$1.rstrip.downcase}#{$2}" }
    end

    # Upcase words with no vowels, e.g JPR Williams
    name.gsub!(/\b([bcdfghjklmnpqrstvwxz]+)\b/i) { |match| $1.upcase }
    # Except Ng
    name.gsub!(/\b(NG)\b/i) { |match| $1.capitalize } # http://en.wikipedia.org/wiki/Ng

    name
  end

  def parameterize string, args = {}
    sep     = args[:sep]      || SLUG_DELIMITER
    rfc3987 = args[:rfc3987]  || false
    filter  = args[:filter]   || (rfc3987 ? FILTER_RFC3987 : FILTER_COMPAT)

    # First we unescape any pct-encoded characters. These might turn into
    # things we want to alter for the slug, like whitespace (e.g. %20)
    parameterized_string = URI.unescape(string)

    # Then we change any whitespace into our separator character
    parameterized_string.gsub!(/\s+/, sep)

    # Then we strip any illegal characters out completely
    parameterized_string.gsub!(filter, '')

    # Make sure separators are not where they shouldn't be
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/i, '')
    end

    # downcase if it's all latin
    parameterized_string.downcase
  end

  #--------------------------------------------------------
  # Constants
  #--------------------------------------------------------

  NONBREAKING_SPACE = "\u00a0"
  ASCII_SPACE       = "\u0020"
  ADFIX_JOINERS     = "[#{ASCII_SPACE}-]"
  SLUG_DELIMITER    =  '-'

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

  NAME_MODIFIERS    = [
    'Al', 'Ap', 'Ben', 'Dell[ae]', 'D[aeiou]', 'De[lr]', 'D[ao]s', 'El', 'La', 'L[eo]',
    'V[ao]n', 'Of', 'St[\.]?'
  ]

  # These are the prefixes and suffixes we want to remove
  # If you add to the list, you can use spaces and dots where appropriate
  # Ensure any single letters are followed by a dot because we'll add one to the string
  # during processing, e.g. "y Cía." should be "y. Cía."
  ADFIXES = {
    prefix: {
      person: [
        'Baron', 'Baroness', 'Capt.', 'Captain', 'Col.', 'Colonel', 'Dame',
        'Doctor', 'Dr.', 'Judge', 'Justice', 'Lady', 'Lieut.', 'Lieutenant',
        'Lord', 'Madame', 'Major', 'Master', 'Matron', 'Messrs.', 'Mgr.',
        'Miss', 'Mister', 'Mlle.', 'Mme.', 'Mons.', 'Mr.', 'Mr. & Mrs.',
        'Mr. and Mrs.', 'Mrs.', 'Msgr.', 'Prof.', 'Professor', 'Rev.',
        'Reverend', 'Sir', 'Sister', 'The Hon.', 'The Lady.', 'The Lord',
        'The Rt. Hon.'
      ],
      organization: [
        'Fa.', 'P.T.', 'P.T. Tbk.', 'U.D.'
      ],
      before:'\\A', after:ADFIX_JOINERS
    },
    suffix: {
      person: [
        'C.I.S.S.P.', 'B.Tech.', 'D.Phil.', 'B.Eng.', 'C.F.A.', 'D.B.E.', 'D.D.S.', 'Eng.D.', 'M.B.A.', 'M.B.E.',
        'M.E.P.', 'M.Eng.', 'M.S.P.', 'O.B.E.', 'P.M.C.', 'P.M.P.', 'P.S.P.', 'B.Ed.', 'B.Sc.', 'Ed.D.', 'LL.B.',
        'LL.D.', 'LL.M.', 'M.Ed.', 'M.Sc.', 'Ph.D.', 'B.A.', 'Esq.', 'J.D.', 'K.C.', 'M.A.', 'M.D.', 'M.P.', 'O.K.',
        'P.A.', 'Q.C.', 'III', 'Jr.', 'Sr.', 'II', 'IV', 'V'
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
        'Part.G.', 'Sh.p.k.', '&. Co.', 'C.X.A.', 'd.n.o.', 'd.o.o.', 'E.A.D.', 'e.h.f.', 'E.P.E.', 'E.S.V.', 'F.C.P.',
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
        'A/S', 'G/S', 'I/S', 'K/S', 'P/S'
      ],
      before:ADFIX_JOINERS, after:'\\z'
    }
  }

  ADFIX_PATTERNS = {}

  [:prefix, :suffix].each do |adfix_type|
    patterns  = {}
    adfix     = ADFIXES[adfix_type]

    [:person, :organization].each do |contact_type|
      with_optional_spaces    = adfix[contact_type].map { |p| p.gsub(ASCII_SPACE,' *') }
      pattern_string          = with_optional_spaces.join('|').gsub('.', '\.*')
      patterns[contact_type]  = /#{adfix[:before]}\(*(?:#{pattern_string})\)*#{adfix[:after]}/i
    end

    ADFIX_PATTERNS[adfix_type] = patterns
  end
end
