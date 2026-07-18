# frozen_string_literal: true

describe NameTamer::Name do
  context 'when there is an invalid byte sequence in UTF-8' do
    let(:name_data) { { n: "\xc3\x28", t: :person, nn: '()', sn: '()', s: '_' } } # Invalid byte sequence in UTF-8

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

  context 'with all ruby versions' do
    let(:names) { YAML.load_file(File.join('spec', 'support', 'names.yml'), permitted_classes: [Symbol]) }

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

    it 'ignores a nonsense contact type' do
      expect(NameTamer['John Smith', contact_type: Kernel].slug).to eq('john-smith')
    end

    it 'announces a change in contact type' do
      nt = described_class.new 'John Smith', contact_type: :person
      nt.contact_type = :organization
      expect(nt.contact_type).to eq(:organization)
    end
  end

  describe 'memoization' do
    let(:name) { described_class.new 'Mr. John Q. Smith III, MD' }

    it 'memoizes the tidied name' do
      expect(name.tidy_name).to be(name.tidy_name)
    end

    it 'memoizes the nice name' do
      expect(name.nice_name).to be(name.nice_name)
    end

    it 'memoizes the simple name' do
      expect(name.simple_name).to be(name.simple_name)
    end
  end

  describe 'names with no usable parts' do
    it 'returns an empty simple name for an empty personal name' do
      expect(described_class.new('', contact_type: :person).simple_name).to eq('')
    end
  end

  describe 'iteration' do
    it 'iterates through the significant words of a name' do
      words = []
      NameTamer['John Smith'].each_word { |w| words << w }
      expect(words).to include('john', 'smith')
    end
  end
end
