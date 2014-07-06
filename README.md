# NameTamer

![Gem Version](http://img.shields.io/gem/v/name-tamer.svg?style=flat)&nbsp;[![Code Climate](http://img.shields.io/codeclimate/github/Xenapto/name-tamer.svg?style=flat)](https://codeclimate.com/github/Xenapto/name-tamer)&nbsp;[![Coverage Status](https://img.shields.io/coveralls/Xenapto/name-tamer.svg?style=flat)](https://coveralls.io/r/Xenapto/name-tamer?branch=master)
[![Developer status](http://img.shields.io/badge/developer-awesome-brightgreen.svg?style=flat)](http://xenapto.com)
![build status](https://circleci.com/gh/Xenapto/name-tamer.png?circle-token=2293f2a1d8463a948c2a2ce4bb3bd99786958c59)

NameTamer: making sense of names

## Installation

Add this line to your application's Gemfile:

    gem 'name-tamer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install name-tamer

## Usage

Examples:

```ruby
NameTamer['Mr. John Q. Smith III, MD'].simple_name # => John Smith
```

Or you can create an instance if you need several versions of the name

```ruby
name_tamer = NameTamer.new 'Mr. John Q. Smith III, MD'
name_tamer.slug # => john-smith
name_tamer.simple_name # => John Smith
name_tamer.nice_name # => John Q. Smith
name_tamer.contact_type # => :person
```

NameTamer will make an intelligent guess at the type of the name but it's not infallible. NameTamer likes it if you tell it whether the name is a person or an organization:

```ruby
name_tamer = NameTamer.new 'Di Doo Doo d.o.o.', contact_type: :organization
name_tamer.simple_name # => Di Doo Doo
```

## Contributing

There must be lots of name suffixes and prefixes that I haven't catered for, so please get in touch if `name-tamer` doesn't recognise one that you've found.

If there are any other common two-word family names that I've missed then please let me know. `name-tamer` tries to make sure Helena Bonham Carter gets slugified to `helena-bonham-carter` and not `helena-carter`, but I'm sure there are loads of two-word family names I don't know about.

Please read all the following articles before contributing:

* [Personal names around the world](http://www.w3.org/International/questions/qa-personal-names)
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
