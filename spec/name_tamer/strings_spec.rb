# frozen_string_literal: true

describe NameTamer::Strings do
  describe '.presence' do
    it 'is nil for an empty string' do
      expect(described_class.presence('')).to be_nil
    end

    it 'returns a non-empty string unchanged' do
      expect(described_class.presence('x')).to eq('x')
    end
  end

  describe '.fix_separators' do
    it 'leaves the string alone when the separator is nil' do
      expect(described_class.fix_separators('a--b', nil)).to eq('a--b')
    end

    it 'leaves the string alone when the separator is empty' do
      expect(described_class.fix_separators('a--b', '')).to eq('a--b')
    end

    it 'squeezes and trims separators otherwise' do
      expect(described_class.fix_separators('-a--b-', '-')).to eq('a-b')
    end
  end

  describe '.safe_unescape' do
    it 'unescapes percent-encoded characters' do
      expect(described_class.safe_unescape('John%20Smith')).to eq('John Smith')
    end

    it 'returns the string unchanged when nothing is escaped' do
      expect(described_class.safe_unescape('John Smith')).to eq('John Smith')
    end
  end

  describe '.fix_mac' do
    it 'capitalizes the letter after Mac in celtic names' do
      expect(described_class.fix_mac('Macdonald')).to eq('MacDonald')
    end

    it 'leaves non-celtic names alone' do
      expect(described_class.fix_mac('Smith')).to eq('Smith')
    end
  end

  describe '.approximate_latin_chars' do
    it 'transliterates characters that resemble latin ones' do
      expect(described_class.approximate_latin_chars('Reñé Straßer')).to eq('Rene Strasser')
    end

    it 'leaves unrecognised non-latin characters alone' do
      expect(described_class.approximate_latin_chars('名前')).to eq('名前')
    end
  end

  describe '.fix_encoding_errors' do
    it 'repairs tell-tale double-encoded UTF-8 sequences' do
      expect(described_class.fix_encoding_errors('RenÃ© Descartes')).to eq('René Descartes')
    end
  end
end
