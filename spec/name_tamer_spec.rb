# encoding: utf-8
require 'spec_helper'
require 'name-tamer'

describe NameTamer do
  let(:names) do
    [
      { n:'John Smith', t: :person, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'JOHN SMITH', t: :person, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'john smith', t: :person, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'Smith, John', t: :person, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'John    Smith', t: :person, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'Smith, John', nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'John J Smith', t: :person, nn:'John J Smith', sn:'John Smith', s:'john-smith' },
      { n:'John J. Smith', t: :person, nn:'John J. Smith', sn:'John Smith', s:'john-smith' },
      { n:'SMITH, Mr John J.R.', t: :person, nn:'John J.R. Smith', sn:'John Smith', s:'john-smith' },
      { n:' SMITH,  Mr John J. R.  ', t: :person, nn:'John J.R. Smith', sn:'John Smith', s:'john-smith' },
      { n:'SMITH, Mr John J.R.', nn:'John J.R. Smith', sn:'John Smith', s:'john-smith' },
      { n:'Mr John J.R. SMITH JD', t: :person, nn:'John J.R. SMITH', sn:'John SMITH', s:'john-smith' },
      { n:'Mr John J.R. SMITH III,JD', t: :person, nn:'John J.R. SMITH', sn:'John SMITH', s:'john-smith' },
      { n:'Mr John J.R. SMITH JD', nn:'John J.R. SMITH', sn:'John SMITH', s:'john-smith' },
      { n:'Mr Jean-Michel SMITH JD', t: :person, nn:'Jean-Michel SMITH', sn:'Jean-Michel SMITH', s:'jean-michel-smith' },
      { n:'Mr Jean Michel-SMITH JD', nn:'Jean Michel-SMITH', sn:'Jean Michel-SMITH', s:'jean-michel-smith' },
      { n:'Dr Martha Lane Fox Ph.D', nn:'Martha Lane Fox', sn:'Martha Lane Fox', s:'martha-lane-fox' },
      { n:'Lane Fox Ph.D, Dr Martha', t: :person, nn:'Martha Lane Fox', sn:'Martha Lane Fox', s:'martha-lane-fox' },
      { n:'Baroness Lane-Fox of Lewisham', t: :person, nn:'Lane-Fox of Lewisham', sn:'Lane-Fox of Lewisham', s:'lane-fox-of-lewisham' },
      { n:'MACDONALDS LLC', nn:'MacDonalds', sn:'MacDonalds', s:'macdonalds' },
      { n:'MACDONALDS LLC', t: :organization, nn:'MacDonalds', sn:'MacDonalds', s:'macdonalds' },
      { n:'macdonalds', t: :organization, nn:'macdonalds', sn:'macdonalds', s:'macdonalds' },
      { n:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble & Grub LLP', t: :organization, nn:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble & Grub', sn:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble and Grub', s:'pugh-pugh-barney-mcgrew-cuthbert-dibble-and-grub' },
      { n:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble & Grub LLP', nn:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble & Grub', sn:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble and Grub', s:'pugh-pugh-barney-mcgrew-cuthbert-dibble-and-grub' },
      { n:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble & Grub LLP', nn:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble & Grub', sn:'Pugh, Pugh, Barney McGrew, Cuthbert, Dibble and Grub', s:'pugh-pugh-barney-mcgrew-cuthbert-dibble-and-grub' },
      { n:'K.V.A. Instruments y Cía S. en C.', nn:'K.V.A. Instruments', sn:'KVA Instruments', s:'kva-instruments' },
      { n:'K. V. A. Instruments y Cía S. en C.', nn:'K.V.A. Instruments', sn:'KVA Instruments', s:'kva-instruments' },
      { n:'J.P. Rangaswami', nn:'J.P. Rangaswami', sn:'JP Rangaswami', s:'jp-rangaswami' },
      { n:'J. P. Rangaswami', nn:'J.P. Rangaswami', sn:'JP Rangaswami', s:'jp-rangaswami' },
      { n:'J P Rangaswami', nn:'J.P. Rangaswami', sn:'JP Rangaswami', s:'jp-rangaswami' },
      { n:'JP Rangaswami', nn:'JP Rangaswami', sn:'JP Rangaswami', s:'jp-rangaswami' },
      { n:'Audrey fforbes', nn:'Audrey fforbes', sn:'Audrey fforbes', s:'audrey-fforbes' },
      { n:'J. Arthur Rank', t: :person, nn:'J. Arthur Rank', sn:'Arthur Rank', s:'arthur-rank' },
      { n:'PHILIP NG', t: :person, nn:'Philip Ng', sn:'Philip Ng', s:'philip-ng' },
      { n:'Super R&D', nn:'Super R&D', sn:'Super R and D', s:'super-r-and-d' },
      { n:'Harry Dean Stanton', t: :person, nn:'Harry Dean Stanton', sn:'Harry Stanton', s:'harry-stanton' },
      { n:'Union Square Ventures', t: :organization, nn:'Union Square Ventures', sn:'Union Square Ventures', s:'union-square-ventures' },
      { n:'J Arthur Rank Inc.', t: :organization, nn:'J Arthur Rank', sn:'J Arthur Rank', s:'j-arthur-rank' },
      { n:'Jean VAN DER VELDE', t: :person, nn:'Jean VAN DER VELDE', sn:'Jean VAN DER VELDE', s:'jean-van-der-velde' },
      { n:'Al Capone', t: :person, nn:'Al Capone', sn:'Al Capone', s:'al-capone' },
      { n:'Fahd al-Saud', t: :person, nn:'Fahd al-Saud', sn:'Fahd al-Saud', s:'fahd-al-saud' },
      { n:'Mehmet al Auouiby', t: :person, nn:'Mehmet al Auouiby', sn:'Mehmet al Auouiby', s:'mehmet-al-auouiby' },
      { n:'Macquarie Bank', t: :organization, nn:'Macquarie Bank', sn:'Macquarie Bank', s:'macquarie-bank' },
      { n:"COMMEDIA DELL'ARTE", t: :organization, nn:"Commedia dell'Arte", sn:"Commedia dell'Arte", s:'commedia-dellarte' },
      { n:'Della Smith', t: :person, nn:'Della Smith', sn:'Della Smith', s:'della-smith' },
      { n:'Antonio DELLA MONTEVERDE', nn:'Antonio DELLA MONTEVERDE', sn:'Antonio DELLA MONTEVERDE', s:'antonio-della-monteverde' },
      { n:'Tony St Clair', t: :person, nn:'Tony St Clair', sn:'Tony St Clair', s:'tony-st-clair' },
      { n:'Seamus O\'Malley', t: :person, nn:'Seamus O\'Malley', sn:'Seamus O\'Malley', s:'seamus-omalley' },
      { n:'SeedCamp', t: :organization, nn:'SeedCamp', sn:'SeedCamp', s:'seedcamp' },
      { n:'Peter Van Der Auwera', t: :person, nn:'Peter Van Der Auwera', sn:'Peter Van Der Auwera', s:'peter-van-der-auwera' },
      { n:'VAN DER AUWERA, Peter', t: :person, nn:'Peter van der Auwera', sn:'Peter van der Auwera', s:'peter-van-der-auwera' },
      { n:'Li Fan', t: :person, nn:'Li Fan', sn:'Li Fan', s:'li-fan' },
      { n:'Fan Li', t: :person, nn:'Fan Li', sn:'Fan Li', s:'fan-li' },
      { n:'Levi Strauss & Co.', nn:'Levi Strauss', sn:'Levi Strauss', s:'levi-strauss' },
      { n:'Standard & Poor\'s', t: :organization, nn:'Standard & Poor\'s', sn:'Standard and Poor\'s', s:'standard-and-poors' },
      { n:'I B M Services', t: :organization, nn:'I.B.M. Services', sn:'IBM Services', s:'ibm-services' },
      { n:'Sean Park DDS', t: :person, nn:'Sean Park', sn:'Sean Park', s:'sean-park' },
      { n:'SEAN MACLISE PARK', t: :person, nn:'Sean Maclise Park', sn:'Sean Park', s:'sean-park' },
      { n:'AJ Hanna', t: :person, nn:'AJ Hanna', sn:'AJ Hanna', s:'aj-hanna' },
      { n:'Free & Clear', t: :organization, nn:'Free & Clear', sn:'Free and Clear', s:'free-and-clear' },
      { n:'Adam D\'ANGELO', t: :person, nn:'Adam D\'ANGELO', sn:'Adam D\'ANGELO', s:'adam-dangelo' },
      { n:'MACKENZIE, Doug', t: :person, nn:'Doug Mackenzie', sn:'Doug Mackenzie', s:'doug-mackenzie' },
      { n:'Up + Down', t: :organization, nn:'Up + Down', sn:'Up plus Down', s:'up-plus-down' },
      { n:'San Francisco Ltd', t: :organization, nn:'San Francisco', sn:'San Francisco', s:'san-francisco' },
      { n:'AT&T', t: :organization, nn:'At&T', sn:'At and T', s:'at-and-t' },
      { n:'SMITH, John, Jr.', t: :person, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'I Heart Movies', t: :organization, nn:'I Heart Movies', sn:'I Heart Movies', s:'i-heart-movies' },
      { n:'Y Combinator', t: :organization, nn:'Y Combinator', sn:'Y Combinator', s:'y-combinator' },
      { n:'Ben\'s 10 Hens', t: :organization, nn:'Ben\'s 10 Hens', sn:'Ben\'s 10 Hens', s:'bens-10-hens' },
      { n:'Elazer Edelman, MD , PhD', t: :person, nn:'Elazer Edelman', sn:'Elazer Edelman', s:'elazer-edelman' },
      { n:'Judith M. O\'Brien', t: :person, nn:'Judith M. O\'Brien', sn:'Judith O\'Brien', s:'judith-obrien' },
      { n:'MORRISON, Van', t: :person, nn:'Van Morrison', sn:'Van Morrison', s:'van-morrison' },
      { n:'i/o Ventures', t: :organization, nn:'i/o Ventures', sn:'i/o Ventures', s:'i-o-ventures' },
      { n:'C T Corporation System', t: :person, nn:'C.T. Corporation System', sn:'CT Corporation System', s:'ct-corporation-system'},
      { n:'C.T. Corporation System', t: :person, nn:'C.T. Corporation System', sn:'CT Corporation System', s:'ct-corporation-system'},
      { n:'CT Corporation System', t: :person, nn:'CT Corporation System', sn:'CT Corporation System', s:'ct-corporation-system'},
      { n:'Corporation Service Company', t: :person, nn:'Corporation Service Company', sn:'Corporation Service Company', s:'corporation-service-company'},
      { n:'Kurshuni,Inc.', t: :organization, nn:'Kurshuni', sn:'Kurshuni', s:'kurshuni' },
      { n:'Cellular Inc-LLC', t: :organization, nn:'Cellular', sn:'Cellular', s:'cellular' },
      { n:'Emtec (AZ) Limited', t: :organization, nn:'Emtec (AZ)', sn:'Emtec (AZ)', s:'emtec-az' },
      { n:'Emtec (LLC) Limited', t: :organization, nn:'Emtec', sn:'Emtec', s:'emtec' },
      { n:'Emtec (XYZ LLC) Limited', t: :organization, nn:'Emtec (XYZ)', sn:'Emtec (XYZ)', s:'emtec-xyz' },
      { n:'Tao Ma', t: :person, nn:'Tao', sn:'Tao', s:'tao' }, # Unfortunate but we can't distinguish between Ma and M.A.
      { n:'(Mr.) Courtney J. Miller, J.D., LL.M.', t: :person, nn:'Courtney J. Miller', sn:'Courtney Miller', s:'courtney-miller' },
      { n:'(Mr Woo) The Window Cleaner', t: :person, nn:'(Woo) The Window Cleaner', sn:'(Woo) Cleaner', s:'woo-cleaner'},
      { n:'DOMINIC MACMURDO', t: :person, nn:'Dominic MacMurdo', sn:'Dominic MacMurdo', s:'dominic-macmurdo' },
      { n:'DOMINIC MACEDO', t: :person, nn:'Dominic Macedo', sn:'Dominic Macedo', s:'dominic-macedo' },
      { n:'DOMINIC MACDONALD', t: :person, nn:'Dominic MacDonald', sn:'Dominic MacDonald', s:'dominic-macdonald' },
      { n:'AGUSTA DO ROMEIRO', t: :person, nn:'Agusta do Romeiro', sn:'Agusta do Romeiro', s:'agusta-do-romeiro' },
      { n:'CARLOS DOS SANTOS', t: :person, nn:'Carlos dos Santos', sn:'Carlos dos Santos', s:'carlos-dos-santos' },
      { n:'유정 신', t: :organization, nn:'유정 신', sn:'유정 신', s:'유정-신' },
      { n:'xxx%52zzz', t: :organization, nn:'xxx%52zzz', sn:'xxx%52zzz', s:'xxxrzzz' },
      { n:'Евгений Болотнов', t: :organization, nn:'Евгений Болотнов', sn:'Евгений Болотнов', s:'Евгений-Болотнов' },
      { n:'김태성', t: :organization, nn:'김태성', sn:'김태성', s:'김태성' },
      { n:'ゴルフスタジアム', t: :organization, nn:'ゴルフスタジアム', sn:'ゴルフスタジアム', s:'ゴルフスタジアム' },
      { n:'我摘', t: :organization, nn:'我摘', sn:'我摘', s:'我摘' },
      { n:'Καρατζάς Στέφανος', t: :organization, nn:'Καρατζάς Στέφανος', sn:'Καρατζάς Στέφανος', s:'Καρατζάς-Στέφανος' },
      { n:'โชติวัน วัฒนลาภ', t: :organization, nn:'โชติวัน วัฒนลาภ', sn:'โชติวัน วัฒนลาภ', s:'โชติวัน-วัฒนลาภ' },
      { n:'張 續寶', t: :organization, nn:'張 續寶', sn:'張 續寶', s:'張-續寶' },
      { n:'Юрий Гайдук', t: :organization, nn:'Юрий Гайдук', sn:'Юрий Гайдук', s:'Юрий-Гайдук' },
      { n:'☣ ©Ʀѱ∏†ʘ Σɏ§†℈Ϻ ☣', t: :organization, nn:'☣ ©Ʀѱ∏†ʘ Σɏ§†℈Ϻ ☣', sn:'☣ ©Ʀѱ∏†ʘ Σɏ§†℈Ϻ ☣', s:'☣-©Ʀѱ∏†ʘ-Σɏ§†℈Ϻ-☣' },
      { n:'♠ KlasikB0i ♠', t: :organization, nn:'♠ KlasikB0i ♠', sn:'♠ KlasikB0i ♠', s:'♠-klasikb0i-♠' },
      { n:'* Shorusan *', t: :organization, nn:'* Shorusan *', sn:'* Shorusan *', s:'shorusan' },
      { n:'项目谷', t: :organization, nn:'项目谷', sn:'项目谷', s:'项目谷' },
      { n:'ООО "Инновационные полимерные адгезивы"', t: :organization, nn:'ООО "Инновационные полимерные адгезивы"', sn:'ООО "Инновационные полимерные адгезивы"', s:'ООО-Инновационные-полимерные-адгезивы' },
      { n:'عبدالله ...', t: :organization, nn:'عبدالله ...', sn:'عبدالله ...', s:'عبدالله' },
      { n:'กมลชนก ทิศไธสง', t: :organization, nn:'กมลชนก ทิศไธสง', sn:'กมลชนก ทิศไธสง', s:'กมลชนก-ทิศไธสง' },
      { n:'יוֹ אָב', t: :organization, nn:'יוֹ אָב', sn:'יוֹ אָב', s:'יוֹ-אָב' },
      { n:'יגאל נימני', t: :organization, nn:'יגאל נימני', sn:'יגאל נימני', s:'יגאל-נימני' },
      { n:'ניסים דניאלי', t: :organization, nn:'ניסים דניאלי', sn:'ניסים דניאלי', s:'ניסים-דניאלי' },
      { n:'مساء الخير', t: :organization, nn:'مساء الخير', sn:'مساء الخير', s:'مساء-الخير' },
      { n:'محمود ياسر', t: :organization, nn:'محمود ياسر', sn:'محمود ياسر', s:'محمود-ياسر' },
      { n:'קובי ביטר', t: :organization, nn:'קובי ביטר', sn:'קובי ביטר', s:'קובי-ביטר' },
      { n:'الملاك الحارس', t: :organization, nn:'الملاك الحارس', sn:'الملاك الحارس', s:'الملاك-الحارس' },
      { n:'কবির হাসান', t: :organization, nn:'কবির হাসান', sn:'কবির হাসান', s:'কবির-হাসান' },
      { nn: '', sn: '', s: '_' },
      { n:'Union Square Ventures', t: 'Organization', nn:'Union Square Ventures', sn:'Union Square Ventures', s:'union-square-ventures' },
      { n:'John Smith', t: 'Person', nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'John Smith', t: :nonsense, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'John Smith', t: Kernel, nn:'John Smith', sn:'John Smith', s:'john-smith' },
      { n:'Ms Jane Smith', t: :person, nn:'Jane Smith', sn:'Jane Smith', s:'jane-smith' },
      { n:'example.com', t: :organization, nn:'example.com', sn:'example.com', s:'example-com' },
      { n:'Hermann Müller', t: :person, nn: 'Hermann Müller', sn: 'Hermann Müller', s:'hermann-muller'},
      { n:'b-to-v Partners AG', t: :organization, nn:'b-to-v Partners', sn:'b-to-v Partners', s:'b-to-v-partners' },
      { n:'*', t: :person, nn: '*', sn: '*', s:'_'},
      { n:'* *', t: :person, nn: '* *', sn: '* *', s:'_'},
      { n:'* Olga *', t: :person, nn: '* Olga *', sn: 'Olga', s:'olga'},
      { n:'* Olga Bedia García *', t: :person, nn: '* Olga Bedia García *', sn: 'Olga García', s:'olga-garcia'},
      { n:'John Smith M.A. (Oxon)', t: :person, nn: 'John Smith', sn: 'John Smith', s: 'john-smith'}
    ]
  end

  it "makes a slug" do
    names.each do |name_data|
      name = name_data[:n]
      NameTamer[name, contact_type:name_data[:t]].slug.should == name_data[:s]
    end
  end

  it "makes a nice name" do
    names.each do |name_data|
      name      = name_data[:n]
      nice_name = NameTamer[name, contact_type:name_data[:t]].nice_name
      nice_name.should == name_data[:nn]
    end
  end

  it "makes a searchable name" do
    names.each do |name_data|
      name = name_data[:n]
      NameTamer[name, contact_type:name_data[:t]].simple_name.should == name_data[:sn]
    end
  end
end

describe 'contact type inference' do
  it 'infers that "Mr. John Smith" is a person' do
    NameTamer['Mr. John Smith'].contact_type.should eq(:person)
  end

  it 'infers that "Di Doo Doo d.o.o." is an organization' do
    NameTamer['Di Doo Doo d.o.o.'].contact_type.should eq(:organization)
  end

  it 'infers that "DiDooDoo" is an organization' do
    NameTamer['DiDooDoo'].contact_type.should eq(:organization)
  end

  it 'infers that "John Smith" is a person' do
    NameTamer['John Smith'].contact_type.should eq(:person)
  end
end
