# Contributing to name_tamer

Thank you for your interest in improving `name_tamer`. Contributions of all
kinds are welcome: bug reports, new name prefixes and suffixes, two-word
family names, documentation improvements and code changes.

## Ways to contribute

- **Report a bug or an unrecognised name** by opening an
  [issue](https://github.com/dominicsayers/name_tamer/issues). Include the
  input name, what `name_tamer` produced and what you expected.
- **Add a prefix or suffix** that `name_tamer` doesn't recognise (see
  [Adding prefixes and suffixes](#adding-prefixes-and-suffixes) below).
- **Add a two-word family name.** `name_tamer` makes sure Helena Bonham
  Carter is slugified to `helena-bonham-carter` and not `helena-carter`,
  but there are plenty of two-word family names it doesn't know about yet.
- **Fix a bug or improve the code** via a pull request.

Before working on name-parsing behaviour, please read
[Falsehoods Programmers Believe About Names](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)
and the other background reading listed in the
[README](README.md#contributing). Names are hard, and many "obvious"
assumptions about them are wrong.

## Getting started

You'll need Ruby 3.3 or newer (the repo includes a `mise.toml` if you use
[mise](https://mise.jdx.dev/)).

```sh
git clone https://github.com/dominicsayers/name_tamer.git
cd name_tamer
bundle install
```

Useful commands:

```sh
bin/rspec           # run the test suite
bin/rubocop         # run the linter
bundle exec rake    # default task, runs the specs
bin/console         # IRB session with name_tamer loaded
```

## Making changes

1. Fork the repository and create a feature branch:
   `git checkout -b my-new-feature`
2. Make your changes, with tests. The specs live in `spec/` and are plain
   RSpec.
3. Make sure `bin/rspec` and `bin/rubocop` both pass.
4. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
   style (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:` and so on), as in
   the existing git history.
5. Push your branch and open a pull request against `main`.

Every pull request runs the CI workflow in
[.github/workflows/test.yml](.github/workflows/test.yml): RuboCop, the spec
suite on Ruby 3.3, 3.4 and 4.0, and a SonarQube analysis. CI must be green
before a PR can be merged.

If your change affects users, add an entry to the *Unreleased* section of
[CHANGELOG.md](CHANGELOG.md) (create the section if it doesn't exist). The
changelog follows the [Keep a Changelog](https://keepachangelog.com/)
format.

## Adding prefixes and suffixes

The lists of recognised prefixes and suffixes (adfixes) live as plain-text
data files in `lib/name_tamer/constants/`, one entry per line:

- `adfixes_prefix_person` — personal prefixes (e.g. `Mr.`, `Dr.`)
- `adfixes_suffix_person` — personal suffixes (e.g. `Ph.D.`, `Jr.`)
- `adfixes_suffix_organization` — organisation suffixes (e.g. `Ltd.`,
  `G.m.b.H.`)

To add one, insert it into the appropriate file (keeping the file's
ordering) and add a spec demonstrating that a name using it is parsed
correctly. The `doc/` directory contains reference CSVs and maintenance
rake tasks (`rake adfixes`, `rake check_existing`) used to curate these
lists.

## Releasing a new version

Releases are for maintainers. Publishing to RubyGems is automated: pushing
a `v*` tag triggers the [Release workflow](.github/workflows/release.yml),
which runs the specs and RuboCop and then publishes the gem using RubyGems
[trusted publishing](https://guides.rubygems.org/trusted-publishing/) (no
local credentials or `gem push` needed).

To cut a release:

1. Make sure `main` is green in CI and your working tree is clean.
2. Bump the version in `lib/name_tamer/version.rb`, following
   [Semantic Versioning](https://semver.org/):
   - **patch** for bug fixes,
   - **minor** for backwards-compatible features (including new adfixes),
   - **major** for breaking changes.
3. Update [CHANGELOG.md](CHANGELOG.md): retitle the *Unreleased* section
   with the new version number and today's date, and check every notable
   change since the last release is listed.
4. Run `bundle install` so `Gemfile.lock` picks up the new gem version.
5. Run the checks locally: `bin/rspec && bin/rubocop`.
6. Commit and push:

   ```sh
   git commit -am 'chore: prepare for release v1.2.3'
   git push
   ```

7. Wait for CI on `main` to pass, then tag the release commit and push the
   tag:

   ```sh
   git tag v1.2.3
   git push origin v1.2.3
   ```

8. The Release workflow will build and publish the gem. Check the
   [Actions tab](https://github.com/dominicsayers/name_tamer/actions) for
   the run, then verify the new version appears on
   [rubygems.org](https://rubygems.org/gems/name_tamer).

The tag must match the version in `lib/name_tamer/version.rb`; the
workflow publishes whatever version the gemspec reports at that commit.

## Code of conduct

Be kind. Remember that names are personal and cultural: when discussing
parsing behaviour, treat all naming conventions with respect.
