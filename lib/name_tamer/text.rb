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
      string.split(%r{(?:[\.\?,:;!]|[[:space:]][/-])[[:space:]]})
    end

    # The string as a slug
    def parameterize
      @parameterize ||= (
        string
        .dup
        .whitespace_to!(separator)
        .invalid_chars_to!(separator)
        .strip_unwanted!(filter)
        .fix_separators!(separator)
        .approximate_latin_chars!
        .presence || '_'
      ).downcase
    end

    def neighbours
      @neighbours ||= NameTamer[string].array.neighbours.map { |a| a.join('-') }
    end

    private

    attr_reader :string, :args

    def initialize(string, args = {})
      @string = string
      @args = args
    end

    def separator
      @seperator ||= args[:sep] || SLUG_DELIMITER
    end

    def rfc3987
      @rfc3987 ||= args[:rfc3987] || false
    end

    def filter
      @filter ||= args[:filter] || (rfc3987 ? FILTER_RFC3987 : FILTER_COMPAT)
    end
  end
end
