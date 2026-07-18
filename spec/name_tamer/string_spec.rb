# frozen_string_literal: true

describe String do
  it 'has a color' do
    expect('xxx'.yellow).to eq("\e[33mxxx\e[0m")
  end

  describe '#presence' do
    it 'is nil for an empty string' do
      expect(''.presence).to be_nil
    end

    it 'returns a non-empty string unchanged' do
      expect('x'.presence).to eq('x')
    end
  end

  describe '#fix_separators!' do
    it 'leaves the string alone when the separator is nil' do
      expect((+'a--b').fix_separators!(nil)).to eq('a--b')
    end

    it 'leaves the string alone when the separator is empty' do
      expect((+'a--b').fix_separators!('')).to eq('a--b')
    end

    it 'squeezes and trims separators otherwise' do
      expect((+'-a--b-').fix_separators!('-')).to eq('a-b')
    end
  end
end
