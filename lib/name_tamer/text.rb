# frozen_string_literal: true

module NameTamer
  class Text
    # All the potential slugs from the string
    # e.g. 'lorem ipsum dolor' -> ['lorem', 'ipsum' ,'dolor', 'lorem-ipsum', 'ipsum-dolor', 'lorem-ipsum-dolor']
    def slugs
      @slugs ||= segments.flat_map { |s| self.class.new(s).neighbours }.uniq
    end

    # Split the string into segments (e.g. sentences)
    def segments
      string.split(%r{(?:[.?,:;!]|[[:space:]][/-])[[:space:]]})
    end

    # The string as a slug
    def parameterize
      @parameterize ||= begin
        slug = Strings.whitespace_to(string, separator)
        slug = Strings.invalid_chars_to(slug, separator)
        slug = Strings.strip_unwanted(slug, filter)
        slug = Strings.fix_separators(slug, separator)
        slug = Strings.approximate_latin_chars(slug)

        (Strings.presence(slug) || '_').downcase
      end
    end

    def neighbours
      @neighbours ||= contiguous_slices(NameTamer[string].array).map { |words| words.join('-') }
    end

    private

    # All the contiguous sub-arrays of an array,
    # e.g. [1, 2] -> [[1], [1, 2], [2]]
    def contiguous_slices(array)
      last_index = array.length - 1
      0.upto(last_index).flat_map { |i| i.upto(last_index).map { |j| array[i..j] } }
    end

    attr_reader :string, :args

    def initialize(string, args = {})
      @string = string
      @args = args
    end

    def separator
      @separator ||= args[:sep] || SLUG_DELIMITER
    end

    def rfc3987
      @rfc3987 ||= args[:rfc3987] || false
    end

    def filter
      @filter ||= args[:filter] || (rfc3987 ? FILTER_RFC3987 : FILTER_COMPAT)
    end
  end
end
