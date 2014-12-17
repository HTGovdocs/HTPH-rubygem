# Htph

Pronunciation: See Bill the Cat of Opus fame. (https://www.google.com/search?tbm=isch&q=bill+the+cat+thbbft)

This is a collection of convenience classes I've used in the HathiTrust Print Holdings (original source of acronym)
and later in the HathiTrust Government Document Repository project. There really isn't anything special with them, and
they may contain several re-inventions of the wheel.

## Installation

Add this line to your application's Gemfile:

    gem 'htph'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install htph

## Usage

In your project Gemfile, put:

    gem 'htph', :path => '/absolute/path/to/root/of/htph/'

Add to you bundle in the root of your project dir:

    cd /root/of/your/project/dir;
    bundle install --path .bundle

Then, in your code:

    require 'htph';
    hd = HTPH::Hathidata::Data.new('foo').open('r');
    ...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
