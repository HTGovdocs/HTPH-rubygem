# Htph

Pronunciation: See Bill the Cat of Opus fame. (https://www.google.com/search?tbm=isch&q=bill+the+cat+thbbft)

This is a collection of convenience classes I've used in the HathiTrust Print Holdings (original source of acronym)
and later in the HathiTrust Government Document Repository project. There really isn't anything special with them, and
they may contain several re-inventions of the wheel.

They are:

* hathibench.rb
    * Simple benchmarking tool
* hathiconf.rb
    * Reads configuration from .env  
* hathidata.rb
    * Reads and writes to files in /data/
* hathidb.rb
    * Provides connection to mysql based on configs in .env 
* hathienv.rb
    * Tells you if you are in dev or prod.
* hathijdbc.rb
    * Similar to hathidb but does it without jdbc-helper
* hathilog.rb
    * Write to logfiles in /log/
* hathinormalize.rb
    * Contains some common normalization rules 

## Installation

Add this line to your application's Gemfile:

    gem 'htph', :git => 'https://github.com/HTGovdocs/HTPH-rubygem.git';

And then execute:

    $ bundle install --path .bundle/

## Usage

    require 'htph';
    hd = HTPH::Hathidata::Data.new('foo').open('r');
    ...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
