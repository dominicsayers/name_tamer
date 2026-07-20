# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-07-20

### Fixed

- The mangled-Á entry in the bad-encoding table is written with an escape
  sequence, so source scanners no longer flag the file as corrupted.

### Changed

- The `NameTamer::Strings` modules use `extend self` instead of
  `module_function`; no public API change.
  
## [1.0.0] - 2026-07-18

### Changed

- **Breaking:** Ruby 3.3 or newer is required; Ruby 2.7–3.2 are no longer
  supported.
- **Breaking:** `name_tamer` no longer defines methods on core classes. The
  `String` helpers (`whitespace_to!`, `approximate_latin_chars!` and friends)
  are now pure functions on `NameTamer::Strings`, and `Array#neighbours` has
  become an internal helper of `NameTamer::Text`. The public API —
  `NameTamer[]`, `NameTamer::Name`, `NameTamer.parameterize` — is unchanged.
- **Breaking:** the terminal-colour `String` methods (`"text".yellow` etc.)
  have been removed; they were unrelated to name taming.

### Fixed

- Multi-word prefixes and suffixes (for example `Chartered F.C.S.I.`,
  `Private Limited`) are stripped correctly again, restoring the behaviour
  of the released 0.6.1 gem after a regression when the adfix lists moved
  into data files.
- The test suite runs on Ruby 3.4+ again (`yaml` is now required explicitly
  and fixtures load under Psych 4's safe defaults).

### Added

- Continuous integration on GitHub Actions: RuboCop plus RSpec on Ruby 3.3,
  3.4 and 4.0, with 100% line and branch coverage enforced.
- SonarQube Cloud analysis with imported coverage and RuboCop reports.
- Releases are published to RubyGems via trusted publishing (OIDC) from a
  gated GitHub Actions environment.

## [0.6.1] and earlier

See the [commit history](https://github.com/dominicsayers/name_tamer/commits/main).
