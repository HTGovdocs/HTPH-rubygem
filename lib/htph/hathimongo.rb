require 'mongo';
require 'htph/hathiconf';

=begin

## Description

Provides connection(s) to the mongodb mentioned in .env.
Uses HTPH::Hathiconf::Conf to read .env.

## Requires the following settings in .env:

dev_mongo_host = x
dev_mongo_port = y
dev_mongo_name = z

## Example usage:

require 'htph';
mongo  = HTPH::Hathimongo::Db.new();
cursor = mongo.conn[:collection].find(...);
cursor.each do |doc|
   puts doc;
end

=end

module HTPH::Hathimongo
  class Db
    attr_reader :conn;
    def initialize ()
      conf = HTPH::Hathiconf::Conf.new();
      host = conf.get('dev_mongo_host');
      port = conf.get('dev_mongo_port');
      name = conf.get('dev_mongo_name');

      if [host,port,name].include?('') then
        raise "Missing one or more mongo settings in .env!";
      end

      @conn = Mongo::Client.new(["#{host}:#{port}"], :database => name);
    end
  end
end
