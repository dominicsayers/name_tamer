# encoding: utf-8
class String
  # Strip illegal characters out completely
  def strip_invalid!(filter)
    self.gsub!(filter, '')
    self # Allows chaining
  end

  def strip_or_self!
    self.strip!
    self # Allows chaining
  end

  # Change any whitespace into our separator character
  def whitespace_to!(separator)
    self.gsub!(/[[:space:]]+/, separator)
    self # Allows chaining
  end

  # Ensure commas have exactly one space after them
  def space_after_comma!
    self.gsub!(/,[[:space:]]*/, ', ')
    self # Allows chaining
  end

  # Change some characters embedded in words to our separator character
  # e.g. example.com -> example-com
  def invalid_chars_to!(separator)
    self.gsub!(/(?<![[:space:]])[\.\/](?![[:space:]])/, separator)
    self # Allows chaining
  end

  # Make sure separators are not where they shouldn't be
  def fix_separators!(separator)
    unless separator.nil? || separator.empty?
      r = Regexp.escape(separator)
      # No more than one of the separator in a row.
      self.gsub!(/#{r}{2,}/, separator)
      # Remove leading/trailing separator.
      self.gsub!(/^#{r}|#{r}$/i, '')
    end

    self # Allows chaining
  end

  # Any characters that resemble latin characters might usefully be
  # transliterated into ones that are easy to type on an anglophone
  # keyboard.
  def approximate_latin_chars!
    self.gsub!(/[^\x00-\x7f]/u) { |char| APPROXIMATIONS[char] || char }
    self # Allows chaining
  end

  def upcase_first_letter!
    self.gsub!(/\b\w/) { |first| first.upcase }
    self # Allows chaining
  end

  def downcase_after_apostrophe!
    self.gsub!(/\'\w\b/) { |c| c.downcase } # Lowercase 's
    self # Allows chaining
  end

  # Our list of terminal characters that indicate a non-celtic name used
  # to include o but we removed it because of MacMurdo.
  def fix_mac!
    if self =~ /\bMac[A-Za-z]{2,}[^acizj]\b/ || self =~ /\bMc/
      self.gsub!(/\b(Ma?c)([A-Za-z]+)/) { |_| Regexp.last_match[1] + Regexp.last_match[2].capitalize }

      # Fix Mac exceptions
      %w(
        MacEdo MacEvicius MacHado MacHar MacHin MacHlin MacIas MacIulis MacKie
        MacKle MacKlin MacKmin MacKmurdo MacQuarie MacLise MacKenzie
      ).each { |mac_name| self.gsub!(/\b#{mac_name}/, mac_name.capitalize) }
    end

    self # Allows chaining
  end

  # Fix ff wierdybonks
  def fix_ff!
    %w(
      Fforbes Fforde Ffinch Ffrench Ffoulkes
    ).each { |ff_name| self.gsub!(ff_name, ff_name.downcase) }

    self # Allows chaining
  end

  # Fixes for name modifiers followed by space
  # Also replaces spaces with non-breaking spaces
  # Fixes for name modifiers followed by an apostrophe, e.g. d'Artagnan, Commedia dell'Arte
  def fix_name_modifiers!
    NAME_MODIFIERS.each do |modifier|
      self.gsub!(/((?:[[:space:]]|^)#{modifier})([[:space:]]+|-)/) do |_|
        "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2].tr(ASCII_SPACE, NONBREAKING_SPACE)}"
      end
    end

    %w(Dell D).each do |modifier|
      self.gsub!(/(.#{modifier}')(\w)/) { |_| "#{Regexp.last_match[1].rstrip.downcase}#{Regexp.last_match[2]}" }
    end

    self # Allows chaining
  end

  # Upcase words with no vowels, e.g JPR Williams
  # Except Ng
  def upcase_initials!
    self.gsub!(/\b([bcdfghjklmnpqrstvwxz]+)\b/i) { |_| Regexp.last_match[1].upcase }
    self.gsub!(/\b(NG)\b/i) { |_| Regexp.last_match[1].capitalize } # http://en.wikipedia.org/wiki/Ng

    self # Allows chaining
  end

  # Fix known last names that have spaces (not hyphens!)
  def nbsp_in_compound_name!
    COMPOUND_NAMES.each do |compound_name|
      self.gsub!(compound_name, compound_name.tr(ASCII_SPACE, NONBREAKING_SPACE))
    end

    self # Allows chaining
  end

  def nbsp_in_name_modifier!
    NAME_MODIFIERS.each do |modifier|
      self.gsub!(/([[:space:]]#{modifier})([[:space:]])/i) { |_| "#{Regexp.last_match[1]}#{NONBREAKING_SPACE}" }
    end

    self # Allows chaining
  end

  def remove_periods_from_initials!
    self.gsub!(/\b([a-z])\./i) { |_| Regexp.last_match[1] }
    self # Allows chaining
  end

  def remove_spaces_from_initials!
    self.gsub!(/\b([a-z])(\.)* \b(?![a-z0-9']{2,})/i) { |_| "#{Regexp.last_match[1]}#{Regexp.last_match[2]}" }
    self # Allows chaining
  end

  def ensure_space_after_initials!
    self.gsub!(/\b([a-z]\.)(?=[a-z0-9]{2,})/i) { |_| "#{Regexp.last_match[1]} " }
    self # Allows chaining
  end

  NONBREAKING_SPACE = "\u00a0"
  ASCII_SPACE       = "\u0020"

  COMPOUND_NAMES  = [
    'Lane Fox', 'Bonham Carter', 'Pitt Rivers', 'Lloyd Webber', 'Sebag Montefiore', 'Holmes à Court', 'Holmes a Court',
    'Baron Cohen', 'Strang Steel',
    'Service Company', 'Corporation Company', 'Corporation System', 'Incorporations Limited'
  ]

  NAME_MODIFIERS  = [
    'Al', 'Ap', 'Ben', 'Dell[ae]', 'D[aeiou]', 'De[lrn]', 'D[ao]s', 'El', 'La', 'L[eo]', 'V[ao]n', 'Of', 'San',
    'St[\.]?', 'Zur'
  ]

  # Transliterations (like the i18n defaults)
  # see https://github.com/svenfuchs/i18n/blob/master/lib/i18n/backend/transliterator.rb
  APPROXIMATIONS = {
    'À' => 'A', 'Á' => 'A', 'Â' => 'A', 'Ã' => 'A', 'Ä' => 'A', 'Å' => 'A', 'Æ' => 'AE',
    'Ç' => 'C', 'È' => 'E', 'É' => 'E', 'Ê' => 'E', 'Ë' => 'E', 'Ì' => 'I', 'Í' => 'I',
    'Î' => 'I', 'Ï' => 'I', 'Ð' => 'D', 'Ñ' => 'N', 'Ò' => 'O', 'Ó' => 'O', 'Ô' => 'O',
    'Õ' => 'O', 'Ö' => 'O', '×' => 'x', 'Ø' => 'O', 'Ù' => 'U', 'Ú' => 'U', 'Û' => 'U',
    'Ü' => 'U', 'Ý' => 'Y', 'Þ' => 'Th', 'ß' => 'ss', 'à' => 'a', 'á' => 'a', 'â' => 'a',
    'ã' => 'a', 'ä' => 'a', 'å' => 'a', 'æ' => 'ae', 'ç' => 'c', 'è' => 'e', 'é' => 'e',
    'ê' => 'e', 'ë' => 'e', 'ì' => 'i', 'í' => 'i', 'î' => 'i', 'ï' => 'i', 'ð' => 'd',
    'ñ' => 'n', 'ò' => 'o', 'ó' => 'o', 'ô' => 'o', 'õ' => 'o', 'ö' => 'o', 'ø' => 'o',
    'ù' => 'u', 'ú' => 'u', 'û' => 'u', 'ü' => 'u', 'ý' => 'y', 'þ' => 'th', 'ÿ' => 'y',
    'Ā' => 'A', 'ā' => 'a', 'Ă' => 'A', 'ă' => 'a', 'Ą' => 'A', 'ą' => 'a', 'Ć' => 'C',
    'ć' => 'c', 'Ĉ' => 'C', 'ĉ' => 'c', 'Ċ' => 'C', 'ċ' => 'c', 'Č' => 'C', 'č' => 'c',
    'Ď' => 'D', 'ď' => 'd', 'Đ' => 'D', 'đ' => 'd', 'Ē' => 'E', 'ē' => 'e', 'Ĕ' => 'E',
    'ĕ' => 'e', 'Ė' => 'E', 'ė' => 'e', 'Ę' => 'E', 'ę' => 'e', 'Ě' => 'E', 'ě' => 'e',
    'Ĝ' => 'G', 'ĝ' => 'g', 'Ğ' => 'G', 'ğ' => 'g', 'Ġ' => 'G', 'ġ' => 'g', 'Ģ' => 'G',
    'ģ' => 'g', 'Ĥ' => 'H', 'ĥ' => 'h', 'Ħ' => 'H', 'ħ' => 'h', 'Ĩ' => 'I', 'ĩ' => 'i',
    'Ī' => 'I', 'ī' => 'i', 'Ĭ' => 'I', 'ĭ' => 'i', 'Į' => 'I', 'į' => 'i', 'İ' => 'I',
    'ı' => 'i', 'Ĳ' => 'IJ', 'ĳ' => 'ij', 'Ĵ' => 'J', 'ĵ' => 'j', 'Ķ' => 'K', 'ķ' => 'k',
    'ĸ' => 'k', 'Ĺ' => 'L', 'ĺ' => 'l', 'Ļ' => 'L', 'ļ' => 'l', 'Ľ' => 'L', 'ľ' => 'l',
    'Ŀ' => 'L', 'ŀ' => 'l', 'Ł' => 'L', 'ł' => 'l', 'Ń' => 'N', 'ń' => 'n', 'Ņ' => 'N',
    'ņ' => 'n', 'Ň' => 'N', 'ň' => 'n', 'ŉ' => "'n", 'Ŋ' => 'NG', 'ŋ' => 'ng',
    'Ō' => 'O', 'ō' => 'o', 'Ŏ' => 'O', 'ŏ' => 'o', 'Ő' => 'O', 'ő' => 'o', 'Œ' => 'OE',
    'œ' => 'oe', 'Ŕ' => 'R', 'ŕ' => 'r', 'Ŗ' => 'R', 'ŗ' => 'r', 'Ř' => 'R', 'ř' => 'r',
    'Ś' => 'S', 'ś' => 's', 'Ŝ' => 'S', 'ŝ' => 's', 'Ş' => 'S', 'ş' => 's', 'Š' => 'S',
    'š' => 's', 'Ţ' => 'T', 'ţ' => 't', 'Ť' => 'T', 'ť' => 't', 'Ŧ' => 'T', 'ŧ' => 't',
    'Ũ' => 'U', 'ũ' => 'u', 'Ū' => 'U', 'ū' => 'u', 'Ŭ' => 'U', 'ŭ' => 'u', 'Ů' => 'U',
    'ů' => 'u', 'Ű' => 'U', 'ű' => 'u', 'Ų' => 'U', 'ų' => 'u', 'Ŵ' => 'W', 'ŵ' => 'w',
    'Ŷ' => 'Y', 'ŷ' => 'y', 'Ÿ' => 'Y', 'Ź' => 'Z', 'ź' => 'z', 'Ż' => 'Z', 'ż' => 'z',
    'Ž' => 'Z', 'ž' => 'z'
  }
end
