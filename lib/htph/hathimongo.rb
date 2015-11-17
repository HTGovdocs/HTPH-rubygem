require 'mongo';
require 'htph/hathiconf';

=begin

Provides connection(s) to the mongodb mentioned in .env.
Uses HTPH::Hathiconf::Conf to read .env.

=end

module HTPH::Hathimongo
  class Mongo

    def initialize ()
      conf = HTPH::Hathiconf::Conf.new();
      host = conf.get('dev_mongo_host');
      port = conf.get('dev_mongo_port');
      db   = conf.get('dev_mongo_db');

      if [host,port,db].include?(nil) then
        raise "Missing one or more mongo settings in .env!";
      end

      conn = Mongo::Client.new("#{host}:#{port}", :database => db);
      return conn;
    end
  end
end
