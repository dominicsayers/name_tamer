# frozen_string_literal: true

module NameTamer
  NONBREAKING_SPACE = "\u00a0"
  ASCII_SPACE = ' '
  ADFIX_JOINERS = "[#{ASCII_SPACE}-]".freeze
  SLUG_DELIMITER = '-'
  ZERO_WIDTH_FILTER = /[\u180E\u200B\u200C\u200D\u2063\uFEFF]/

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
  ALPHA = 'A-Za-z'
  DIGIT = '0-9'
  UCSCHAR = '\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF'
  IUNRESERVED = "#{ALPHA}#{DIGIT}\\-\\._~#{UCSCHAR}".freeze
  SUBDELIMS = '!$&\'\(\)\*+,;='
  ISEGMENT_NZ_NC = "#{IUNRESERVED}#{SUBDELIMS}@".freeze # pct-encoded not needed
  FILTER_RFC3987 = /[^#{ISEGMENT_NZ_NC}]/
  FILTER_COMPAT = /[^#{ALPHA}#{DIGIT}\-_#{UCSCHAR}]/

  # These are the prefixes and suffixes we want to remove
  # If you add to the list, you can use spaces and dots where appropriate
  # Ensure any single letters are followed by a dot because we'll add one to the string
  # during processing, e.g. "y Cia." should be "y. Cia."

  private_class_method def self.get_constants_from(filename)
    File.readlines(Pathname.new(__dir__).join('constants', filename), chomp: true).reject(&:empty?)
  end

  ADFIXES = {
    prefix: {
      person: get_constants_from('adfixes_prefix_person'),
      organization: [
        'Fa.',
        'P.T. Tbk.',
        'P.T.',
        'U.D.',
      ],
      before: '\\A', after: ADFIX_JOINERS
    },
    suffix: {
      person: get_constants_from('adfixes_suffix_person'),
      organization: get_constants_from('adfixes_suffix_organization'),
      before: ADFIX_JOINERS, after: '\\z'
    },
  }.freeze

  CONTACT_TYPES = %i[person organization].freeze

  ADFIX_PATTERNS = %i[prefix suffix].to_h do |adfix_type|
    patterns = {}
    adfix = ADFIXES[adfix_type]

    CONTACT_TYPES.each do |ct|
      with_optional_spaces = adfix[ct].map { |p| p.gsub(ASCII_SPACE, ' *') }
      pattern_string = with_optional_spaces.join('|').gsub('.', '\.*')
      patterns[ct] = /#{adfix[:before]}\(*(?:#{pattern_string})[®™)]*#{adfix[:after]}/i
    end

    [adfix_type, patterns]
  end
end
