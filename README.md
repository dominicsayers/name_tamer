# NameTamer

[![Gem version](https://badge.fury.io/rb/name_tamer.svg)](https://rubygems.org/gems/name_tamer)
[![Gem downloads](https://img.shields.io/gem/dt/name_tamer.svg)](https://rubygems.org/gems/name_tamer)
[![Test](https://github.com/dominicsayers/name_tamer/actions/workflows/test.yml/badge.svg)](https://github.com/dominicsayers/name_tamer/actions/workflows/test.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=dominicsayers_name_tamer&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=dominicsayers_name_tamer)

NameTamer: making sense of names

## Installation

Add the gem to your application:

```console
bundle add name_tamer
```

Or install it yourself:

```console
gem install name_tamer
```

## Supported Ruby versions

`name_tamer` supports the Ruby versions in [normal or security maintenance
upstream](https://www.ruby-lang.org/en/downloads/branches/) — currently
Ruby 3.3, 3.4 and 4.0. The test suite runs against all of them.

## Usage

Examples:

```ruby
NameTamer['Mr. John Q. Smith III, MD'].simple_name # => John Smith
```

Or you can create an instance if you need several versions of the name

```ruby
name_tamer = NameTamer::Name.new 'Mr. John Q. Smith III, MD'
name_tamer.slug # => john-smith
name_tamer.simple_name # => John Smith
name_tamer.nice_name # => John Q. Smith
name_tamer.contact_type # => :person
```

NameTamer will make an intelligent guess at the type of the name but it's
not infallible. NameTamer likes it if you tell it whether the name is a
person or an organization:

```ruby
name_tamer = NameTamer::Name.new 'Acme Group Private Limited', contact_type: :organization
name_tamer.simple_name # => Acme Group
```

## Upgrading from 0.x

Version 1.0.0 makes three breaking changes:

- Ruby 3.3 or newer is required.
- The gem no longer defines methods on `String` or `Array`. The helpers are
  pure functions on `NameTamer::Strings` (e.g.
  `NameTamer::Strings.approximate_latin_chars('Reñé')`), and each returns a
  new string instead of mutating the receiver.
- The terminal-colour `String` methods (`'text'.yellow` and friends) are
  gone; use a dedicated gem such as `rainbow` if you need them.

The documented API — `NameTamer[]`, `NameTamer::Name`,
`NameTamer.parameterize` — is unchanged.

## Contributing

There must be lots of name suffixes and prefixes that I haven't catered
for, so please get in touch if `name_tamer` doesn't recognise one that
you've found.

If there are any other common two-word family names that I've missed then
please let me know. `name_tamer` tries to make sure Helena Bonham Carter
gets slugified to `helena-bonham-carter` and not `helena-carter`, but I'm
sure there are loads of two-word family names I don't know about.

Please read all the following articles before contributing:

- [Personal names around the world](https://www.w3.org/International/questions/qa-personal-names)
- [Falsehoods Programmers Believe About Names](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)
- [Last Name First](http://www.solidether.net/article/last-name-first/)
- [Namae (名前)](https://github.com/berkmancenter/namae)
- [Matts Name Parser](https://github.com/mericson/people)
- [Types of business entity](http://en.wikipedia.org/wiki/Types_of_business_entity)
- [List of professional designations in the United States](http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(USA))
- [List of post-nominal letters (United Kingdom)](http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(United_Kingdom))
- [Nobiliary particle](http://en.wikipedia.org/wiki/Nobiliary_particle)
- [Spanish naming customs](http://en.wikipedia.org/wiki/Spanish_naming_customs)
- [Unified style sheet for linguistics](http://linguistlist.org/pubs/tocs/JournalUnifiedStyleSheet2007.pdf) [PDF]

### How to contribute

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

## Acknowledgements

1. Thanks to Ryan Bigg for the
   [guide to making your first gem](https://github.com/radar/guides/blob/master/gem-development.md)
