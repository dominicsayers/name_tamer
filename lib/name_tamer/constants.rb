module NameTamer
  NONBREAKING_SPACE = "\u00a0".freeze
  ASCII_SPACE = ' '.freeze
  ADFIX_JOINERS = "[#{ASCII_SPACE}-]".freeze
  SLUG_DELIMITER = '-'.freeze
  ZERO_WIDTH_FILTER = /[\u180E\u200B\u200C\u200D\u2063\uFEFF]/

  # Constants for parameterizing Unicode strings for IRIs
  #
  # Allowed characters in an IRI segment are defined by RFC 3987
  # (https://tools.ietf.org/html/rfc3987#section-2.2) as follows:
  #
  #    isegment-nz-nc = 1*( iunreserved / pct-encoded / sub-delims
  #                         / "@" )
  #                   ; non-zero-length segment without any colon ":"
  #
  #    iunreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~" / ucschar
  #
  #    pct-encoded    = "%" HEXDIG HEXDIG
  #
  #    sub-delims     = "!" / "$" / "&" / "'" / "(" / ")"
  #                   / "*" / "+" / "," / ";" / "="
  #
  #    ucschar        = %xA0-D7FF / %xF900-FDCF / %xFDF0-FFEF
  #                   / %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
  #                   / %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
  #                   / %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
  #                   / %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
  #                   / %xD0000-DFFFD / %xE1000-EFFFD
  #
  # Note that we can't use Unicode code points above \uFFFF because of
  # regex limitations, so we'll ignore ucschar above that point.
  #
  # We're using the most restrictive segment definition (isegment-nz-nc)
  # to avoid any possible problems with the IRI that it one day might
  # get placed in.
  ALPHA = 'A-Za-z'.freeze
  DIGIT = '0-9'.freeze
  UCSCHAR = '\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF'.freeze
  IUNRESERVED = "#{ALPHA}#{DIGIT}\\-\\._~#{UCSCHAR}".freeze
  SUBDELIMS = '!$&\'\(\)\*+,;='.freeze
  ISEGMENT_NZ_NC = "#{IUNRESERVED}#{SUBDELIMS}@".freeze # pct-encoded not needed
  FILTER_RFC3987 = /[^#{ISEGMENT_NZ_NC}]/
  FILTER_COMPAT = /[^#{ALPHA}#{DIGIT}\-_#{UCSCHAR}]/

  # These are the prefixes and suffixes we want to remove
  # If you add to the list, you can use spaces and dots where appropriate
  # Ensure any single letters are followed by a dot because we'll add one to the string
  # during processing, e.g. "y Cia." should be "y. Cia."
  ADFIXES = {
    prefix: {
      person: [
        'Baron', 'Baroness', 'Capt.', 'Captain', 'Col.', 'Colonel', 'Dame',
        'Doctor', 'Dr.', 'Judge', 'Justice', 'Lady', 'Lieut.', 'Lieutenant',
        'Lord', 'Madame', 'Major', 'Master', 'Matron', 'Messrs.', 'Mgr.',
        'Miss', 'Mister', 'Mlle.', 'Mme.', 'Mons.', 'Mr.', 'Mr. & Mrs.',
        'Mr. and Mrs.', 'Mrs.', 'Msgr.', 'Ms.', 'Prof.', 'Professor', 'Rev.',
        'Reverend', 'Sir', 'Sister', 'The Hon.', 'The Lady.', 'The Lord',
        'The Rt. Hon.'
      ],
      organization: [
        'Fa.', 'P.T.', 'P.T. Tbk.', 'U.D.'
      ],
      before: '\\A', after: ADFIX_JOINERS
    },
    suffix: {
      person: [
        'Chartered F.C.S.I.', 'Chartered M.C.S.I.', 'I.F.R.S. Certified', 'F.Inst.L.M.', 'C.I.S.S.P.', 'F.C.I.P.S.',
        'M.R.I.C.S.', 'T.M.I.E.T.', 'Dip. D.M.', 'A.A.M.S.', 'A.C.C.A.', 'A.C.M.A.', 'A.I.F.A.', 'A.W.M.A.', 'C.A.I.A.',
        'C.A.P.M.', 'C.C.I.M.', 'C.D.F.A.', 'C.E.P.P.', 'C.F.B.S.', 'C.G.M.A.', 'C.I.T.P.', 'C.L.T.C.', 'C.P.C.C.',
        'C.R.P.C.', 'C.R.P.S.', 'C.S.O.X.', 'C.S.S.D.', 'F.B.C.S.', 'F.C.C.A.', 'F.C.M.I.', 'F.C.S.I.', 'F.I.E.T.',
        'F.I.R.P.', 'M.I.E.T.', 'M.S.F.S.', 'M.Sc. D.', 'O.R.S.C.', 'R.I.C.P.', 'B.Tech.', 'Cantab.', 'Ch.F.C.',
        'D.Phil.', 'I.T.I.L. v3', 'M.Io.D.', 'S.C.M.P', 'A.C.A.', 'A.C.C.', 'A.E.P.', 'A.I.F.', 'A.S.A.', 'B.Eng.',
        'C.B.V.', 'C.E.M.', 'C.Eng.', 'C.F.A.', 'C.F.F.', 'C.F.P.', 'C.F.S.', 'C.G.A.', 'C.G.B.', 'C.G.P.', 'C.I.M.',
        'C.L.P.', 'C.L.U.', 'C.M.A.', 'C.M.T.', 'C.P.A.', 'C.T.A.', 'C.W.S.', 'D.B.E.', 'D.D.S.', 'D.V.M.', 'E.R.P.',
        'Eng.D.', 'F.C.A.', 'F.P.C.', 'F.R.M.', 'F.R.M.', 'G.S.P.', 'L.P.S.', 'M.B.A.', 'M.B.E.', 'M.E.P.', 'M.Eng.',
        'M.Jur.', 'M.P.A.', 'M.S.F.', 'M.S.P.', 'O.B.E.', 'P.C.C.', 'P.F.S.', 'P.H.R.', 'P.M.C.', 'P.M.P.', 'P.M.P.',
        'P.S.P.', 'R.F.C.', 'V.M.D.', 'B.Ed.', 'B.Sc.', 'Ed.D.', 'Ed.M.', 'Hons.', 'LL.B.', 'LL.D.', 'LL.M.', 'M.Ed.',
        'M.Sc.', 'Oxon.', 'Ph.D.', 'B.A.', 'C.A.', 'E.A.', 'Esq.', 'J.D.', 'K.C.', 'M.A.', 'M.D.', 'M.P.', 'M.S.',
        'O.K.', 'P.A.', 'Q.C.', 'R.D.', 'III', 'Jr.', 'Sr.', 'II', 'IV', 'V'
      ],
      organization: [
        'S. de R.L. de C.V.', 'S.A.P.I. de C.V.', 'y. Cía. S. en C.', 'Private Limited', 'S.M. Pte. Ltd.',
        'Cía. S. C. A.', 'y. Cía. S. C.', 'S.A. de C.V.', 'spol. s.r.o.', '(Pty.) Ltd.', '(Pvt.) Ltd.', 'A.D.S.I.Tz.',
        'S.p. z.o.o.', '(Pvt.)Ltd.', 'akc. spol.', 'Cía. Ltda.', 'E.B.V.B.A.', 'P. Limited', 'S. de R.L.', 'S.I.C.A.V.',
        'S.P.R.L.U.', 'А.Д.С.И.Ц.', '(P.) Ltd.', 'C. por A.', 'Comm.V.A.', 'Ltd. Şti.', 'Plc. Ltd.', 'Pte. Ltd.',
        'Pty. Ltd.', 'Pvt. Ltd.', 'Soc. Col.', 'A.M.B.A.', 'A.S.B.L.', 'A.V.E.E.', 'B.V.B.A.', 'B.V.I.O.', 'C.V.B.A.',
        'C.V.O.A.', 'E.E.I.G.', 'E.I.R.L.', 'E.O.O.D.', 'E.U.R.L.', 'F.M.B.A.', 'G.m.b.H.', 'Ges.b.R.', 'K.G.a.A.',
        'L.L.L.P.', 'Ltd. Co.', 'Ltd. Co.', 'M.E.P.E.', 'n.y.r.t.', 'O.V.E.E.', 'P.E.E.C.', 'P.L.L.C.', 'P.L.L.C.',
        'S. en C.', 'S.a.p.a.', 'S.A.R.L.', 'S.à.R.L.', 'S.A.S.U.', 'S.C.e.I.', 'S.C.O.P.', 'S.C.p.A.', 'S.C.R.I.',
        'S.C.R.L.', 'S.M.B.A.', 'S.P.R.L.', 'Е.О.О.Д.', '&. Cie.', 'and Co.', 'Comm.V.', 'Limited', 'P. Ltd.',
        'Part.G.', 'Sh.p.k.', '&. Co.', 'C.X.A.', 'd.n.o.', 'd.o.o.', 'E.A.D.', 'e.h.f.', 'E.P.E.', 'E.S.V.', 'F.C.P.',
        'F.I.E.', 'G.b.R.', 'G.I.E.', 'G.M.K.', 'G.S.K.', 'H.U.F.', 'K.D.A.', 'k.f.t.', 'k.h.t.', 'k.k.t.', 'L.L.C.',
        'L.L.P.', 'o.h.f.', 'O.H.G.', 'O.O.D.', 'O.y.j.', 'p.l.c.', 'P.S.U.', 'S.A.E.', 'S.A.S.', 'S.C.A.', 'S.C.E.',
        'S.C.S.', 'S.E.M.', 'S.E.P.', 's.e.s.', 'S.G.R.', 'S.N.C.', 'S.p.A.', 'S.P.E.', 'S.R.L.', 's.r.o.', 'Unltd.',
        'V.O.F.', 'V.o.G.', 'v.o.s.', 'V.Z.W.', 'z.r.t.', 'А.А.Т.', 'Е.А.Д.', 'З.А.Т.', 'К.Д.А.', 'О.О.Д.', 'Т.А.А.',
        '股份有限公司', 'Ap.S.', 'Corp.', 'ltda.', 'Sh.A.', 'st.G.', 'Ultd.', 'a.b.', 'A.D.', 'A.E.', 'A.G.', 'A.S.',
        'A.Ş.', 'A.y.', 'B.M.', 'b.t.', 'B.V.', 'C.A.', 'C.V.', 'd.d.', 'e.c.', 'E.E.', 'e.G.', 'E.I.', 'E.P.', 'E.T.',
        'E.U.', 'e.v.', 'G.K.', 'G.P.', 'h.f.', 'Inc.', 'K.D.', 'K.G.', 'K.K.', 'k.s.', 'k.v.', 'K.y.', 'L.C.', 'L.P.',
        'Ltd.', 'N.K.', 'N.L.', 'N.V.', 'O.E.', 'O.G.', 'O.Ü.', 'O.y.', 'P.C.', 'p.l.', 'Pty.', 'PUP.', 'Pvt.', 'r.t.',
        'S.A.', 'S.D.', 'S.E.', 's.f.', 'S.L.', 'S.P.', 'S.s.', 'T.K.', 'T.Ü.', 'U.Ü.', 'Y.K.', 'А.Д.', 'І.П.', 'К.Д.',
        'ПУП.', 'С.Д.', 'בע"מ', '任意組合', '匿名組合', '合同会社', '合名会社', '合資会社', '有限会社', '有限公司', '株式会社',
        'A/S', 'G/S', 'I/S', 'K/S', 'P/S', 'S/A'
      ],
      before: ADFIX_JOINERS, after: '\\z'
    }
  }.freeze

  ADFIX_PATTERNS = Hash[%i[prefix suffix].map do |adfix_type|
    patterns = {}
    adfix = ADFIXES[adfix_type]

    %i[person organization].each do |ct|
      with_optional_spaces = adfix[ct].map { |p| p.gsub(ASCII_SPACE, ' *') }
      pattern_string = with_optional_spaces.join('|').gsub('.', '\.*')
      patterns[ct] = /#{adfix[:before]}\(*(?:#{pattern_string})[®™\)]*#{adfix[:after]}/i
    end

    [adfix_type, patterns]
  end]
end
