# encoding: utf-8
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'csv'
require 'name-tamer'

desc 'Build prefixes and suffixes'
task :adfixes do
  pp = []
  po = []
  sp = []
  so = []

  CSV.foreach("#{File.dirname(__FILE__)}/prefixes.csv", headers: true) do |row|
    if row[2] == 'person'
      pp << row[0]
    else
      po << row[0]
    end
  end

  CSV.foreach("#{File.dirname(__FILE__)}/suffixes.csv", headers: true) do |row|
    if row[2] == 'person'
      sp << row[0]
    else
      so << row[0]
    end
  end

  puts "'" + pp.join("', '") + "'"
  puts "'" + po.join("', '") + "'"
  puts "'" + sp.join("', '") + "'"
  puts "'" + so.join("', '") + "'"
end

task :check_existing do
  [
    'Chartered F.C.S.I.',
    'C.I.S.S.P.', 'T.M.I.E.T.', 'A.C.C.A.', 'C.I.T.P.', 'F.B.C.S.', 'F.C.C.A.', 'F.C.M.I.', 'F.I.E.T.', 'F.I.R.P.',
    'M.I.E.T.', 'B.Tech.',
    'Cantab.', 'D.Phil.', 'I.T.I.L. v3', 'B.Eng.', 'C.Eng.', 'M.Jur.', 'C.F.A.', 'D.B.E.', 'C.L.P.',
    'D.D.S.', 'D.V.M.', 'Eng.D.', 'A.C.A.', 'C.T.A.', 'E.R.P.', 'F.C.A.', 'F.P.C.', 'F.R.M.', 'M.B.A.', 'M.B.E.',
    'M.E.P.', 'M.Eng.', 'M.Jur.', 'M.S.P.', 'O.B.E.', 'P.M.C.', 'P.M.P.', 'P.S.P.', 'V.M.D.', 'B.Ed.', 'B.Sc.',
    'Ed.D.', 'Hons.', 'LL.B.',
    'LL.D.', 'LL.M.', 'M.Ed.', 'M.Sc.', 'Oxon.', 'Ph.D.', 'B.A.', 'Esq.', 'J.D.', 'K.C.', 'M.A.', 'M.D.', 'M.P.',
    'O.K.', 'P.A.', 'Q.C.', 'III', 'Jr.', 'Sr.', 'II', 'IV', 'V'
  ].each do |suffix|
    fail suffix unless NameTamer::ADFIXES[:suffix][:person].include? suffix
  end
end
