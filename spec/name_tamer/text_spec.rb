# frozen_string_literal: true

describe NameTamer::Text do
  describe '#segments' do
    let(:string) do
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' \
        'Nullam venenatis? Risus eu: auctor feugiat; libero nisl congue ' \
        'arcu - eget molestie metus / erat eu diam'
    end

    let(:expected_segments) do
      [
        'Lorem ipsum dolor sit amet',
        'consectetur adipiscing elit',
        'Nullam venenatis',
        'Risus eu',
        'auctor feugiat',
        'libero nisl congue arcu',
        'eget molestie metus',
        'erat eu diam',
      ]
    end

    it 'splits a string into segments at appropriate boundaries' do
      text = described_class.new string

      expect(text.segments).to include(*expected_segments)
    end
  end

  describe '#slugs' do
    let(:string) { 'Lorem Ipsum Limited, lorem ipsum dolor. Dolor Mr Sit Amet.' }
    let(:text) { described_class.new string }
    let(:slugs) { text.slugs }

    it 'compiles all the potential slugs into an array' do
      expect(slugs).to include(
        'lorem', 'lorem-ipsum', 'ipsum', 'lorem-ipsum-dolor', 'ipsum-dolor',
        'dolor', 'dolor-mr', 'dolor-mr-sit', 'dolor-mr-sit-amet', 'mr',
        'mr-sit', 'mr-sit-amet', 'sit', 'sit-amet', 'amet'
      )
    end

    it 'has the expected number of slugs' do
      expect(slugs.length).to eq 15
    end
  end
end
