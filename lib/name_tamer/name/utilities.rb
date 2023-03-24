# frozen_string_literal: true

module NameTamer
  class Name
    module Utilities
      def contact_type_from(args)
        args_ct = args[:contact_type]
        return unless args_ct

        ct = args_ct.is_a?(Symbol) ? args_ct : args_ct.dup
        ct = ct.to_s unless [String, Symbol].include? ct.class
        ct.downcase! if ct.instance_of?(String)
        ct = ct.to_sym
        ct = nil unless %i[person organization].include? ct

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
  end
end
