# frozen_string_literal: true

module NameTamer
  class Name
    module PrivateMethodsSimpleName
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
        @simple_name = +"#{first_name}#{separator}#{last_name}"
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
    end
  end
end
