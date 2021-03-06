## NameTamer

[![Gem version](https://badge.fury.io/rb/name_tamer.svg)](https://rubygems.org/gems/name_tamer)
[![Gem downloads](https://img.shields.io/gem/dt/name_tamer.svg)](https://rubygems.org/gems/name_tamer)
[![Build Status](https://travis-ci.org/dominicsayers/name_tamer.svg?branch=master)](https://travis-ci.org/dominicsayers/name_tamer)
[![Code Climate](https://codeclimate.com/github/dominicsayers/name_tamer/badges/gpa.svg)](https://codeclimate.com/github/dominicsayers/name_tamer)
[![Test Coverage](https://codeclimate.com/github/dominicsayers/name_tamer/badges/coverage.svg)](https://codeclimate.com/github/dominicsayers/name_tamer/coverage)
[![Security](https://hakiri.io/github/dominicsayers/name_tamer/master.svg)](https://hakiri.io/github/dominicsayers/name_tamer/master)

NameTamer: making sense of names

## Installation

Add this line to your application's Gemfile:

    gem 'name_tamer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install name_tamer

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

NameTamer will make an intelligent guess at the type of the name but it's not infallible. NameTamer likes it if you tell it whether the name is a person or an organization:

```ruby
name_tamer = NameTamer::Name.new 'Di Doo Doo d.o.o.', contact_type: :organization
name_tamer.simple_name # => Di Doo Doo
```

## Contributing

There must be lots of name suffixes and prefixes that I haven't catered for, so please get in touch if `name_tamer` doesn't recognise one that you've found.

If there are any other common two-word family names that I've missed then please let me know. `name_tamer` tries to make sure Helena Bonham Carter gets slugified to `helena-bonham-carter` and not `helena-carter`, but I'm sure there are loads of two-word family names I don't know about.

Please read all the following articles before contributing:

* [Personal names around the world](https://www.w3.org/International/questions/qa-personal-names)
* [Falsehoods Programmers Believe About Names](https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/)
* [Last Name First](http://www.solidether.net/article/last-name-first/)
* [Namae (名前)](https://github.com/berkmancenter/namae)
* [Matts Name Parser](https://github.com/mericson/people)
* [Types of business entity](http://en.wikipedia.org/wiki/Types_of_business_entity)
* [List of professional designations in the United States](http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(USA))
* [List of post-nominal letters (United Kingdom)](http://en.wikipedia.org/wiki/List_of_post-nominal_letters_(United_Kingdom))
* [Nobiliary particle](http://en.wikipedia.org/wiki/Nobiliary_particle)
* [Spanish naming customs](http://en.wikipedia.org/wiki/Spanish_naming_customs)
* [Unified style sheet for linguistics](http://linguistlist.org/pubs/tocs/JournalUnifiedStyleSheet2007.pdf) [PDF]

### How to contribute

1.  Fork it
1.  Create your feature branch (`git checkout -b my-new-feature`)
1.  Commit your changes (`git commit -am 'Add some feature'`)
1.  Push to the branch (`git push origin my-new-feature`)
1.  Create new Pull Request

## Acknowledgements

1.  Thanks to Ryan Bigg for the guide to making your first gem https://github.com/radar/guides/blob/master/gem-development.md
