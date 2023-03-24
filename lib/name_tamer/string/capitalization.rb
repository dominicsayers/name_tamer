# frozen_string_literal: true

class String
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

  # Upcase words with no vowels, e.g JPR Williams
  # Except Ng
  def upcase_initials!
    gsub!(/\b([bcdfghjklmnpqrstvwxz]+)\b/i) { |_| Regexp.last_match[1].upcase }
    gsub!(/\b(NG)\b/i) { |_| Regexp.last_match[1].capitalize } || self # http://en.wikipedia.org/wiki/Ng
  end
end
