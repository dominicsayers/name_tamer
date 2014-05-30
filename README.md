# NameTamer

[![Gem Version](https://badge.fury.io/rb/name-tamer.png)](http://badge.fury.io/rb/name-tamer)
[![Code Climate](https://codeclimate.com/github/Xenapto/name-tamer.png)](https://codeclimate.com/github/Xenapto/name-tamer)
[![Dependency Status](https://gemnasium.com/Xenapto/name-tamer.png)](https://gemnasium.com/Xenapto/name-tamer)
![build status](https://circleci.com/gh/Xenapto/name-tamer.png?circle-token=dd3a51864d33f6506b18a355bc901b90c0df3b3b)

NameTamer: deploying Rails projects to Ubuntu using Foreman

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

```ruby
name_tamer = NameTamer['Mr. John Q. Smith III, MD']
name_tamer.slug # => john-smith
name_tamer.nice_name # => John Q. Smith
```

## Contributing

1.  Fork it
1.  Create your feature branch (`git checkout -b my-new-feature`)
1.  Commit your changes (`git commit -am 'Add some feature'`)
1.  Push to the branch (`git push origin my-new-feature`)
1.  Create new Pull Request

## Acknowledgements

1.  Thanks to Ryan Bigg for the guide to making your first gem https://github.com/radar/guides/blob/master/gem-development.md
