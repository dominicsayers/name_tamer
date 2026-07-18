# frozen_string_literal: true

module NameTamer
  module Strings
    module_function

    def upcase_first_letter(string)
      string.gsub(/\b\w/, &:upcase)
    end

    def downcase_after_apostrophe(string)
      string.gsub(/'\w\b/, &:downcase) # Lowercase 's
    end

    # Our list of terminal characters that indicate a non-celtic name used
    # to include o but we removed it because of MacMurdo.
    def fix_mac(string)
      return string unless /\bMac[A-Za-z]{2,}[^acizj]\b/.match?(string) || /\bMc/.match?(string)

      fixed = string.gsub(/\b(Ma?c)([A-Za-z]+)/) { Regexp.last_match[1] + Regexp.last_match[2].capitalize }

      # Fix Mac exceptions
      MAC_EXCEPTIONS.reduce(fixed) { |name, mac_name| name.gsub(/\b#{mac_name}/, mac_name.capitalize) }
    end

    # Fix ff wierdybonks
    def fix_ff(string)
      FF_NAMES.reduce(string) { |name, ff_name| name.gsub(ff_name, ff_name.downcase) }
    end

    # Upcase words with no vowels, e.g JPR Williams
    # Except Ng http://en.wikipedia.org/wiki/Ng
    def upcase_initials(string)
      string
        .gsub(/\b([bcdfghjklmnpqrstvwxz]+)\b/i) { Regexp.last_match[1].upcase }
        .gsub(/\b(NG)\b/i) { Regexp.last_match[1].capitalize }
    end

    MAC_EXCEPTIONS = %w[
      MacEdo MacEvicius MacHado MacHar MacHin MacHlin MacIas MacIulis MacKie
      MacKle MacKlin MacKmin MacKmurdo MacQuarie MacLise MacKenzie
    ].freeze

    FF_NAMES = %w[Fforbes Fforde Ffinch Ffrench Ffoulkes].freeze
  end
end
