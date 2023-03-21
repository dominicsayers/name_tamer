# frozen_string_literal: true

class String
  unless respond_to? :presence
    def presence
      self unless empty?
    end
  end

  # Strip illegal characters out completely
  def strip_unwanted!(filter)
    substitute!(filter, '')
  end

  def strip_or_self!
    strip! || self
  end

  # Change any whitespace into our separator character
  def whitespace_to!(separator)
    substitute!(/[[:space:]]+/, separator)
  end

  # Ensure commas have exactly one space after them
  def space_around_comma!
    substitute!(/[[:space:]]*,[[:space:]]*/, ',
    ')
  end

  # Change some characters embedded in words to our separator character
  # e.g. example.com -> example-com
  def invalid_chars_to!(separator)
    substitute!(%r{(?<![[:space:]])[./](?![[:space:]])}, separator)
  end

  # Unescape percent-encoded characters
  # This might introduce UTF-8 invalid byte sequence
  # so we take precautions
  def safe_unescape!
    string = CGI.unescape(gsub('+', '%2B'))
    return self if self == string

    replace string
    ensure_safe!
  end

  # Remove HTML entities
  def unescape_html!
    replace CGI.unescapeHTML self
  end

  # Make sure separators are not where they shouldn't be
  def fix_separators!(separator)
    return self if separator.nil? || separator.empty?

    r = Regexp.escape(separator)

    # No more than one of the separator in a row.
    substitute!(/#{r}{2,}/, separator)

    # Remove leading/trailing separator.
    substitute!(/^#{r}|#{r}$/i, '')
  end

  # Any characters that resemble latin characters might usefully be
  # transliterated into ones that are easy to type on an anglophone
  # keyboard.
  def approximate_latin_chars!
    gsub!(/[^\x00-\x7f]/u) { |char| APPROXIMATIONS[char] || char } || self
  end

  # Strings that were wrongly encoded with single-byte encodings sometimes have
  # tell-tale substrings that we can put back into the correct UTF-8 character
  def fix_encoding_errors!
    gsub!(BAD_ENCODING_PATTERNS) { |substring| BAD_ENCODING[substring] || substring } || self
  end

  def upcase_first_letter!
    gsub!(/\b\w/, &:upcase) || self
  end

  def downcase_after_apostrophe!
    gsub!(/'\w\b/, &:downcase) || self # Lowercase 's
  end

  # Our list of terminal characters that indicate a non-celtic name used
  # to include o but we removed it because of MacMurdo.
  def fix_mac!
    if self =~ /\bMac[A-Za-z]{2,}[^acizj]\b/ || self =~ /\bMc/
      gsub!(/\b(Ma?c)([A-Za-z]+)/) { |_| Regexp.last_match[1] + Regexp.last_match[2].capitalize }

      # Fix Mac exceptions
      %w[
        MacEdo MacEvicius MacHado MacHar MacHin MacHlin MacIas MacIulis MacKie
        MacKle MacKlin MacKmin MacKmurdo MacQuarie MacLise MacKenzie
      ].each { |mac_name| substitute!(/\b#{mac_name}/, mac_name.capitalize) }
    end

    self # Allows chaining
  end

  # Fix ff wierdybonks
  def fix_ff!
    %w[
      Fforbes Fforde Ffinch Ffrench Ffoulkes
    ].each { |ff_name| substitute!(ff_name, ff_name.downcase) }

    self # Allows chaining
  end

  # Fixes for name modifiers followed by space
  # Also replaces spaces with non-breaking spaces
  # Fixes for name modifiers followed by an apostrophe, e.g. d'Artagnan, Commedia dell'Arte
  def fix_name_modifiers!
    NAME_MODIFIERS.each do |modifier|
      gsub!(/((?:[[:space:]]|^)#{modifier})([[:space:]]+|-)/) do |_|
        "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2].tr(ASCII_SPACE, NONBREAKING_SPACE)}"
      end
    end

    fix_apostrophe_modifiers!
    self # Allows chaining
  end

  def fix_apostrophe_modifiers!
    %w[Dell D].each do |modifier|
      gsub!(/(.#{modifier}')(\w)/) { |_| "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2]}" }
    end

    self # Allows chaining
  end

  # Upcase words with no vowels, e.g JPR Williams
  # Except Ng
  def upcase_initials!
    gsub!(/\b([bcdfghjklmnpqrstvwxz]+)\b/i) { |_| Regexp.last_match[1].upcase }
    gsub!(/\b(NG)\b/i) { |_| Regexp.last_match[1].capitalize } || self # http://en.wikipedia.org/wiki/Ng
  end

  # Fix known last names that have spaces (not hyphens!)
  def nbsp_in_compound_name!
    COMPOUND_NAMES.each do |compound_name|
      substitute!(compound_name, compound_name.tr(ASCII_SPACE, NONBREAKING_SPACE))
    end

    self # Allows chaining
  end

  def nbsp_in_name_modifier!
    NAME_MODIFIERS.each do |modifier|
      gsub!(/([[:space:]]#{modifier})([[:space:]])/i) { |_| "#{Regexp.last_match[1]}#{NONBREAKING_SPACE}" }
    end

    self # Allows chaining
  end

  def remove_periods_from_initials!
    gsub!(/\b([a-z])\./i) { |_| Regexp.last_match[1] } || self
  end

  def remove_spaces_from_initials!
    gsub!(/\b([a-z])(\.)* \b(?![a-z0-9'\u00C0-\u00FF]{2,})/i) do |_|
      "#{Regexp.last_match[1]}#{Regexp.last_match[2]}"
    end || self
  end

  def ensure_space_after_initials!
    gsub!(/\b([a-z]\.)(?=[a-z0-9]{2,})/i) { |_| "#{Regexp.last_match[1]} " } || self
  end

  def ensure_safe!
    encode!('UTF-8', invalid: :replace, undef: :replace, replace: '') # Doesn't fully work in Ruby 2.0
  end

  def substitute!(pattern, replacement)
    gsub!(pattern, replacement) || self
  end

  NONBREAKING_SPACE = "\u00a0"
  ASCII_SPACE = ' '

  COMPOUND_NAMES = [
    # Known families with a space in their surname
    'Baron Cohen',
    'Bonham Carter',
    'Holmes a Court',
    'Holmes à Court',
    'Lane Fox',
    'Lloyd Webber',
    'Pitt Rivers',
    'Sebag Montefiore',
    'Strang Steel',
    'Wedgwood Benn',
    'Wingfield Digby',
    # Sometimes companies appear as people
    'Corporation Company',
    'Corporation System',
    'Incorporations Limited',
    'Service Company',
  ].freeze

  NAME_MODIFIERS = [
    'Al',
    'Ap',
    'Ben',
    'D[aeiou]',
    'D[ao]s',
    'De[lrn]',
    'Dell[ae]',
    'El',
    'L[eo]',
    'La',
    'Of',
    'San',
    'St[\.]?',
    'V[ao]n',
    'Zur',
  ].freeze

  # Transliterations (like the i18n defaults)
  # see https://github.com/svenfuchs/i18n/blob/master/lib/i18n/backend/transliterator.rb
  APPROXIMATIONS = {
    'İ' => 'I',
    '×' => 'x',
    'ß' => 'ss',
    'À' => 'A',
    'à' => 'a',
    'Á' => 'A',
    'á' => 'a',
    'Â' => 'A',
    'â' => 'a',
    'Ã' => 'A',
    'ã' => 'a',
    'Ä' => 'A',
    'ä' => 'a',
    'Å' => 'A',
    'å' => 'a',
    'Æ' => 'AE',
    'æ' => 'ae',
    'Ç' => 'C',
    'ç' => 'c',
    'È' => 'E',
    'è' => 'e',
    'É' => 'E',
    'é' => 'e',
    'Ê' => 'E',
    'ê' => 'e',
    'Ë' => 'E',
    'ë' => 'e',
    'Ì' => 'I',
    'ì' => 'i',
    'Í' => 'I',
    'í' => 'i',
    'Î' => 'I',
    'î' => 'i',
    'Ï' => 'I',
    'ï' => 'i',
    'Ð' => 'D',
    'ð' => 'd',
    'Ñ' => 'N',
    'ñ' => 'n',
    'Ò' => 'O',
    'ò' => 'o',
    'Ó' => 'O',
    'ó' => 'o',
    'Ô' => 'O',
    'ô' => 'o',
    'Õ' => 'O',
    'õ' => 'o',
    'Ö' => 'O',
    'ö' => 'o',
    'Ø' => 'O',
    'ø' => 'o',
    'Ù' => 'U',
    'ù' => 'u',
    'Ú' => 'U',
    'ú' => 'u',
    'Û' => 'U',
    'û' => 'u',
    'Ü' => 'U',
    'ü' => 'u',
    'Ý' => 'Y',
    'ý' => 'y',
    'Þ' => 'Th',
    'þ' => 'th',
    'ÿ' => 'y',
    'Ÿ' => 'Y',
    'Ā' => 'A',
    'ā' => 'a',
    'Ă' => 'A',
    'ă' => 'a',
    'Ą' => 'A',
    'ą' => 'a',
    'Ć' => 'C',
    'ć' => 'c',
    'Ĉ' => 'C',
    'ĉ' => 'c',
    'Ċ' => 'C',
    'ċ' => 'c',
    'Č' => 'C',
    'č' => 'c',
    'Ď' => 'D',
    'ď' => 'd',
    'Đ' => 'D',
    'đ' => 'd',
    'Ē' => 'E',
    'ē' => 'e',
    'Ĕ' => 'E',
    'ĕ' => 'e',
    'Ė' => 'E',
    'ė' => 'e',
    'Ę' => 'E',
    'ę' => 'e',
    'Ě' => 'E',
    'ě' => 'e',
    'Ĝ' => 'G',
    'ĝ' => 'g',
    'Ğ' => 'G',
    'ğ' => 'g',
    'Ġ' => 'G',
    'ġ' => 'g',
    'Ģ' => 'G',
    'ģ' => 'g',
    'Ĥ' => 'H',
    'ĥ' => 'h',
    'Ħ' => 'H',
    'ħ' => 'h',
    'Ĩ' => 'I',
    'ĩ' => 'i',
    'Ī' => 'I',
    'ī' => 'i',
    'Ĭ' => 'I',
    'ĭ' => 'i',
    'Į' => 'I',
    'į' => 'i',
    'ı' => 'i',
    'Ĳ' => 'IJ',
    'ĳ' => 'ij',
    'Ĵ' => 'J',
    'ĵ' => 'j',
    'Ķ' => 'K',
    'ķ' => 'k',
    'ĸ' => 'k',
    'Ĺ' => 'L',
    'ĺ' => 'l',
    'Ļ' => 'L',
    'ļ' => 'l',
    'Ľ' => 'L',
    'ľ' => 'l',
    'Ŀ' => 'L',
    'ŀ' => 'l',
    'Ł' => 'L',
    'ł' => 'l',
    'Ń' => 'N',
    'ń' => 'n',
    'Ņ' => 'N',
    'ņ' => 'n',
    'Ň' => 'N',
    'ň' => 'n',
    'ŉ' => "'n",
    'Ŋ' => 'NG',
    'ŋ' => 'ng',
    'Ō' => 'O',
    'ō' => 'o',
    'Ŏ' => 'O',
    'ŏ' => 'o',
    'Ő' => 'O',
    'ő' => 'o',
    'Œ' => 'OE',
    'œ' => 'oe',
    'Ŕ' => 'R',
    'ŕ' => 'r',
    'Ŗ' => 'R',
    'ŗ' => 'r',
    'Ř' => 'R',
    'ř' => 'r',
    'Ś' => 'S',
    'ś' => 's',
    'Ŝ' => 'S',
    'ŝ' => 's',
    'Ş' => 'S',
    'ş' => 's',
    'Š' => 'S',
    'š' => 's',
    'Ţ' => 'T',
    'ţ' => 't',
    'Ť' => 'T',
    'ť' => 't',
    'Ŧ' => 'T',
    'ŧ' => 't',
    'Ũ' => 'U',
    'ũ' => 'u',
    'Ū' => 'U',
    'ū' => 'u',
    'Ŭ' => 'U',
    'ŭ' => 'u',
    'Ů' => 'U',
    'ů' => 'u',
    'Ű' => 'U',
    'ű' => 'u',
    'Ų' => 'U',
    'ų' => 'u',
    'Ŵ' => 'W',
    'ŵ' => 'w',
    'Ŷ' => 'Y',
    'ŷ' => 'y',
    'Ź' => 'Z',
    'ź' => 'z',
    'Ż' => 'Z',
    'ż' => 'z',
    'ž' => 'z',
    'Ž' => 'Z',
  }.freeze

  # When strings are mistakenly encoded as single-byte character sets, instead
  # of UTF-8, there are some distinctive character combinations that we can spot
  # and fix
  # Useful table here http://www.i18nqa.com/debug/utf8-debug.html
  BAD_ENCODING = {
    "\xC3\x8D" => 'Í',
    "\xC3\x8F" => 'Ï',
    "\xC3\x90" => 'Ð',
    "\xC3\x9D" => 'Ý',
    'Â ' => ' ',
    'Â¡' => '¡',
    'Â¢' => '¢',
    'Â£' => '£',
    'Â¤' => '¤',
    'Â¥' => '¥',
    'Â¦' => '¦',
    'Â§' => '§',
    'Â¨' => '¨',
    'Â©' => '©',
    'Âª' => 'ª',
    'Â«' => '«',
    'Â¬' => '¬',
    'Â­' => '­',
    'Â®' => '®',
    'Â¯' => '¯',
    'Â°' => '°',
    'Â±' => '±',
    'Â²' => '²',
    'Â³' => '³',
    'Â´' => '´',
    'Âµ' => 'µ',
    'Â¶' => '¶',
    'Â·' => '·',
    'Â¸' => '¸',
    'Â¹' => '¹',
    'Âº' => 'º',
    'Â»' => '»',
    'Â¼' => '¼',
    'Â½' => '½',
    'Â¾' => '¾',
    'Â¿' => '¿',
    'â‚¬' => '€',
    'â„¢' => '™',
    'â€' => '”', # Note the invisible Ux009D in the key
    'â€ ' => '†',
    'â€¡' => '‡',
    'â€¢' => '•',
    'â€¦' => '…',
    'â€°' => '‰',
    'â€²' => '′', # Manually added. Some seem to use this instead of Ux2019
    'â€¹' => '‹',
    'â€º' => '›',
    'â€œ' => '“',
    'â€š' => '‚',
    'â€ž' => '„',
    'â€˜' => '‘',
    'â€“' => '–',
    'â€”' => '—',
    'â€™' => '’',
    'Ã ' => 'à',
    'Ã¡' => 'á',
    'Ã¢' => 'â',
    'Ã£' => 'ã',
    'Ã¤' => 'ä',
    'Ã¥' => 'å',
    'Ã¦' => 'æ',
    'Ã§' => 'ç',
    'Ã¨' => 'è',
    'Ã©' => 'é',
    'Ãª' => 'ê',
    'Ã«' => 'ë',
    'Ã¬' => 'ì',
    'Ã­' => 'í',
    'Ã®' => 'î',
    'Ã¯' => 'ï',
    'Ã°' => 'ð',
    'Ã±' => 'ñ',
    'Ã²' => 'ò',
    'Ã³' => 'ó',
    'Ã´' => 'ô',
    'Ãµ' => 'õ',
    'Ã¶' => 'ö',
    'Ã·' => '÷',
    'Ã¸' => 'ø',
    'Ã¹' => 'ù',
    'Ãº' => 'ú',
    'Ã»' => 'û',
    'Ã¼' => 'ü',
    'Ã½' => 'ý',
    'Ã¾' => 'þ',
    'Ã¿' => 'ÿ',
    'ÃŸ' => 'ß',
    'ÃŒ' => 'Ì',
    'Ãœ' => 'Ü',
    'ÃŠ' => 'Ê',
    'Ãš' => 'Ú',
    'ÃŽ' => 'Î',
    'Ãž' => 'Þ',
    'Ãƒ' => 'Ã',
    'Ãˆ' => 'È',
    'Ã˜' => 'Ø',
    'Ã–' => 'Ö',
    'Ã—' => '×',
    'Ã‘' => 'Ñ',
    'Ã’' => 'Ò',
    'Ã‚' => 'Â',
    'Ã“' => 'Ó',
    'Ã”' => 'Ô',
    'Ã„' => 'Ä',
    'Ã†' => 'Æ',
    'Ã‡' => 'Ç',
    'Ã•' => 'Õ',
    'Ã…' => 'Å',
    'Ã‰' => 'É',
    'Ã‹' => 'Ë',
    'Ã›' => 'Û',
    'Ã€' => 'À',
    'Ã™' => 'Ù',
    'Ã�' => 'Á',
    'Å ' => 'Š',
    'Å¡' => 'š',
    'Å¸' => 'Ÿ',
    'Å½' => 'Ž',
    'Å¾' => 'ž',
    'Å’' => 'Œ',
    'Å“' => 'œ',
    'Æ’' => 'ƒ',
    'Ëœ' => '˜',
    'Ë†' => 'ˆ',
    "\x00" => '', # Manually added to avoid Bad Argument exception
  }.freeze

  BAD_ENCODING_PATTERNS = /(#{BAD_ENCODING.keys.join('|')})/.freeze

  # Colorize strings
  colors = %w[black red green yellow blue magenta cyan white]

  colors.each_with_index do |fg_color, i|
    fg = 30 + i
    define_method(fg_color) { ansi_attributes(fg) }

    colors.each_with_index do |bg_color, j|
      define_method("#{fg_color}_on_#{bg_color}") { ansi_attributes(fg, 40 + j) }
    end
  end

  def ansi_attributes(*args)
    "\e[#{args.join(';')}m#{self}\e[0m"
  end
end
