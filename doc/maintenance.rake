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
    raise suffix unless NameTamer::ADFIXES[:suffix][:person].include? suffix
  end

  [
    'S. de R.L. de C.V.', 'S.A.P.I. de C.V.', 'y. Cía. S. en C.', 'Private Limited', 'S.M. Pte. Ltd.', 'Cía. S. C. A.',
    'y. Cía. S. C.', 'S.A. de C.V.', 'spol. s.r.o.', '(Pty.) Ltd.', '(Pvt.) Ltd.', 'A.D.S.I.Tz.', 'S.p. z.o.o.',
    '(Pvt.)Ltd.', 'akc. spol.', 'Cía. Ltda.', 'E.B.V.B.A.', 'P. Limited', 'S. de R.L.', 'S.I.C.A.V.', 'S.P.R.L.U.',
    'А.Д.С.И.Ц.', '(P.) Ltd.', 'C. por A.', 'Comm.V.A.', 'Ltd. Şti.', 'Plc. Ltd.', 'Pte. Ltd.', 'Pty. Ltd.',
    'Pvt. Ltd.', 'Soc. Col.', 'A.M.B.A.', 'A.S.B.L.', 'A.V.E.E.', 'B.V.B.A.', 'B.V.I.O.', 'C.V.B.A.', 'C.V.O.A.',
    'E.E.I.G.', 'E.I.R.L.', 'E.O.O.D.', 'E.U.R.L.', 'F.M.B.A.', 'G.m.b.H.', 'Ges.b.R.', 'K.G.a.A.', 'L.L.L.P.',
    'Ltd. Co.', 'Ltd. Co.', 'M.E.P.E.', 'n.y.r.t.', 'O.V.E.E.', 'P.E.E.C.', 'P.L.L.C.', 'P.L.L.C.', 'S. en C.',
    'S.a.p.a.', 'S.A.R.L.', 'S.à.R.L.', 'S.A.S.U.', 'S.C.e.I.', 'S.C.O.P.', 'S.C.p.A.', 'S.C.R.I.', 'S.C.R.L.',
    'S.M.B.A.', 'S.P.R.L.', 'Е.О.О.Д.', '&. Cie.', 'and Co.', 'Comm.V.', 'Limited', 'P. Ltd.', 'Part.G.', 'Sh.p.k.',
    '&. Co.', 'C.X.A.', 'd.n.o.', 'd.o.o.', 'E.A.D.', 'e.h.f.', 'E.P.E.', 'E.S.V.', 'F.C.P.', 'F.I.E.', 'G.b.R.',
    'G.I.E.', 'G.M.K.', 'G.S.K.', 'H.U.F.', 'K.D.A.', 'k.f.t.', 'k.h.t.', 'k.k.t.', 'L.L.C.', 'L.L.P.', 'o.h.f.',
    'O.H.G.', 'O.O.D.', 'O.y.j.', 'p.l.c.', 'P.S.U.', 'S.A.E.', 'S.A.S.', 'S.C.A.', 'S.C.E.', 'S.C.S.', 'S.E.M.',
    'S.E.P.', 's.e.s.', 'S.G.R.', 'S.N.C.', 'S.p.A.', 'S.P.E.', 'S.R.L.', 's.r.o.', 'Unltd.', 'V.O.F.', 'V.o.G.',
    'v.o.s.', 'V.Z.W.', 'z.r.t.', 'А.А.Т.', 'Е.А.Д.', 'З.А.Т.', 'К.Д.А.', 'О.О.Д.', 'Т.А.А.', '股份有限公司', 'Ap.S.',
    'Corp.', 'ltda.', 'Sh.A.', 'st.G.', 'Ultd.', 'a.b.', 'A.D.', 'A.E.', 'A.G.', 'A.S.', 'A.Ş.', 'A.y.', 'B.M.', 'b.t.',
    'B.V.', 'C.A.', 'C.V.', 'd.d.', 'e.c.', 'E.E.', 'e.G.', 'E.I.', 'E.P.', 'E.T.', 'E.U.', 'e.v.', 'G.K.', 'G.P.',
    'h.f.', 'Inc.', 'K.D.', 'K.G.', 'K.K.', 'k.s.', 'k.v.', 'K.y.', 'L.C.', 'L.P.', 'Ltd.', 'N.K.', 'N.L.', 'N.V.',
    'O.E.', 'O.G.', 'O.Ü.', 'O.y.', 'P.C.', 'p.l.', 'Pty.', 'PUP.', 'Pvt.', 'r.t.', 'S.A.', 'S.D.', 'S.E.', 's.f.',
    'S.L.', 'S.P.', 'S.s.', 'T.K.', 'T.Ü.', 'U.Ü.', 'Y.K.', 'А.Д.', 'І.П.', 'К.Д.', 'ПУП.', 'С.Д.', 'בע"מ', '任意組合',
    '匿名組合', '合同会社', '合名会社', '合資会社', '有限会社', '有限公司', '株式会社', 'A/S', 'G/S', 'I/S', 'K/S', 'P/S', 'S/A'
  ].each do |suffix|
    raise suffix unless NameTamer::ADFIXES[:suffix][:organization].include? suffix
  end
end
