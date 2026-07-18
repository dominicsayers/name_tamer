# frozen_string_literal: true

module NameTamer
  class Name
    module PrivateMethodsNiceName
      def unescape
        @tidy_name = Strings.unescape_html(Strings.safe_unescape(Strings.ensure_safe(@tidy_name)))
      end

      def remove_zero_width
        @tidy_name = Strings.strip_unwanted(@tidy_name, ZERO_WIDTH_FILTER)
      end

      def tidy_spacing
        @tidy_name = Strings.whitespace_to(Strings.space_around_comma(@tidy_name).strip, ASCII_SPACE)
      end

      def fix_encoding_errors
        @tidy_name = Strings.fix_encoding_errors(@tidy_name)
      end

      # Remove spaces from groups of initials
      def consolidate_initials
        @tidy_name = Strings.ensure_space_after_initials(Strings.remove_spaces_from_initials(@tidy_name))
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
          @nice_name = "(#{@nice_name}"
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
        @nice_name = Strings.nbsp_in_name_modifier(Strings.nbsp_in_compound_name(@nice_name))
      end
    end
  end
end
