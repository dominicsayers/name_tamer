# NameTamer

![Gem Version](http://img.shields.io/gem/v/name-tamer.svg?style=flat)&nbsp;[![Coverage Status](https://img.shields.io/coveralls/Xenapto/name-tamer.svg?style=flat)](https://coveralls.io/r/Xenapto/name-tamer?branch=master)
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
name_tamer.nice_name # => John Q. Smith
name_tamer.contact_type # => :person
```

NameTamer will make an intelligent guess at the type of the name but it's not infallible. NameTamer likes it if you tell it whether the name is a person or an organization:

```ruby
name_tamer = NameTamer.new 'Di Doo Doo d.o.o.', contact_type: :organization
name_tamer.simple_name # => Di Doo Doo
```

## Contributing

1.  Fork it
1.  Create your feature branch (`git checkout -b my-new-feature`)
1.  Commit your changes (`git commit -am 'Add some feature'`)
1.  Push to the branch (`git push origin my-new-feature`)
1.  Create new Pull Request

## Acknowledgements

1.  Thanks to Ryan Bigg for the guide to making your first gem https://github.com/radar/guides/blob/master/gem-development.md
