# frozen_string_literal: true

describe NameTamer::Text do
  describe '#segments' do
    it 'splits a string into segments at appropriate boundaries' do
      string = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' \
               'Nullam venenatis? Risus eu: auctor feugiat; libero nisl congue ' \
               'arcu - eget molestie metus / erat eu diam'

      text = NameTamer::Text.new string

      expect(text.segments).to include(
        'Lorem ipsum dolor sit amet',
        'consectetur adipiscing elit',
        'Nullam venenatis',
        'Risus eu',
        'auctor feugiat',
        'libero nisl congue arcu',
        'eget molestie metus',
        'erat eu diam'
      )
    end
  end

  describe '#slugs' do
    it 'compiles all the potential slugs into an array' do
      string = 'Lorem Ipsum Limited, lorem ipsum dolor. Dolor Mr Sit Amet.'
      text = NameTamer::Text.new string
      slugs = text.slugs

      expect(slugs).to include(
        'lorem', 'lorem-ipsum', 'ipsum', 'lorem-ipsum-dolor', 'ipsum-dolor',
        'dolor', 'dolor-mr', 'dolor-mr-sit', 'dolor-mr-sit-amet', 'mr',
        'mr-sit', 'mr-sit-amet', 'sit', 'sit-amet', 'amet'
      )

      expect(slugs.length).to eq 15
    end
  end
end
