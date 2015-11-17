require 'mongo';
require 'htph/hathiconf';

=begin

Provides connection(s) to the mongodb mentioned in .env.
Uses HTPH::Hathiconf::Conf to read .env.

=end

module HTPH::Hathimongo
  class Db

    def initialize ()
      conf = HTPH::Hathiconf::Conf.new();
      host = conf.get('dev_mongo_host');
      port = conf.get('dev_mongo_port');
      name = conf.get('dev_mongo_name');

      if [host,port,name].include?('') then
        raise "Missing one or more mongo settings in .env!";
      end

      conn = Mongo::Client.new(["#{host}:#{port}"], :database => name);
      return conn;
    end
  end
end
