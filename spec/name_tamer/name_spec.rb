# encoding: utf-8

describe NameTamer::Name do
  context 'invalid byte sequence in UTF-8' do
    let(:name_data) { { n: "\xc3\x28", t: :person, nn: '()', sn: '()', s: '_' } } # Invalid byte sequence in UTF-8

    if Gem::Version.new(RUBY_VERSION) <= Gem::Version.new('2')
      it 'fails to correct invalid byte sequence' do
        name = name_data[:n]
        expect { NameTamer[name, contact_type: name_data[:t]].slug }.to raise_error(
          ArgumentError,
          'invalid byte sequence in UTF-8'
        )
      end
    else
      it 'makes a slug' do
        name = name_data[:n]
        expect(NameTamer[name, contact_type: name_data[:t]].slug).to eq(name_data[:s])
      end

      it 'makes a nice name' do
        name = name_data[:n]
        nice_name = NameTamer[name, contact_type: name_data[:t]].nice_name
        expect(nice_name).to eq(name_data[:nn])
      end

      it 'makes a searchable name' do
        name = name_data[:n]
        expect(NameTamer[name, contact_type: name_data[:t]].simple_name).to eq(name_data[:sn])
      end
    end
  end

  context 'all ruby versions' do
    let(:names) { YAML.load_file(File.join('spec', 'support', 'names.yml')) }

    it 'loads the examples correctly' do
      expect(names.length).to eq(151) # Number of examples
    end

    it 'makes a slug' do
      names.each do |name_data|
        name = name_data[:n]
        expect(NameTamer[name, contact_type: name_data[:t]].slug).to eq(name_data[:s].downcase)
      end
    end

    it 'makes a nice name' do
      names.each do |name_data|
        name = name_data[:n]
        nice_name = NameTamer[name, contact_type: name_data[:t]].nice_name
        expect(nice_name).to eq(name_data[:nn])
      end
    end

    it 'makes a searchable name' do
      names.each do |name_data|
        name = name_data[:n]
        expect(NameTamer[name, contact_type: name_data[:t]].simple_name).to eq(name_data[:sn])
      end
    end
  end
end

describe 'contact type inference' do
  it 'infers that "Mr. John Smith" is a person' do
    expect(NameTamer['Mr. John Smith'].contact_type).to eq(:person)
  end

  it 'infers that "Di Doo Doo d.o.o." is an organization' do
    expect(NameTamer['Di Doo Doo d.o.o.'].contact_type).to eq(:organization)
  end

  it 'infers that "DiDooDoo" is an organization' do
    expect(NameTamer['DiDooDoo'].contact_type).to eq(:organization)
  end

  it 'infers that "John Smith" is a person' do
    expect(NameTamer['John Smith'].contact_type).to eq(:person)
  end
end
