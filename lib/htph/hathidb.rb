require 'java';
require 'jdbc-helper';
require 'io/console';
require 'htph/hathiconf';
require 'htph/hathienv';

=begin

Provides connection(s) to the mysql database(s) mentioned in .env.
Uses HTPH::Hathiconf::Conf to read .env.

You can only access the prod db if calling from the prod environment,
as defined by HTPH::Hathienv.

If you want to enter username and password interactively, use the
_interactive methods.

=end

module HTPH::Hathidb
  class Db

    def initialize ()
      @conf = HTPH::Hathiconf::Conf.new();
    end

    # Implicitly 'dev'.
    def get_conn()
      conn = JDBCHelper::Connection.new(
       :driver           => @conf.get('db_driver'),
       :url              => @conf.get('db_url'),
       :user             => @conf.get('db_user'),
       :password         => @conf.get('db_pw'),
       :useCursorFetch   => 'true',
       :defaultFetchSize => 10000,
       );
      return conn;
    end

    # Explicitly 'prod'.
    def get_prod_conn()
      if HTPH::Hathienv::Env.is_dev?() then
        raise "You cannot access the production database from here.";
      end

      conn = JDBCHelper::Connection.new(
       :driver           => @conf.get('prod_db_driver'),
       :url              => @conf.get('prod_db_url'),
       :user             => @conf.get('prod_db_user'),
       :password         => @conf.get('prod_db_pw'),
       :useCursorFetch   => 'true',
       :defaultFetchSize => 10000,
       );
      return conn;
    end

    def get_interactive()
      # Like get_conn but getting username & password from stdin.
      print "\n";
      print "User: >>";
      db_user = STDIN.noecho(&:gets).strip;
      print "\n";
      print "Password: >>";
      db_pw   = STDIN.noecho(&:gets).strip;
      print "\n";
      conn = JDBCHelper::Connection.new(
       :driver           => @conf.get('db_driver'),
       :url              => @conf.get('db_url'),
       :user             => db_user,
       :password         => db_pw,
       :useCursorFetch   => 'true',
       :defaultFetchSize => 10000,
       );
      return conn;
    end

    def get_prod_interactive()
      # Like get_prod_conn but getting username & password from stdin.
      if HTPH::Hathienv::Env.is_dev?() then
        raise "You cannot access the production database from here.";
      end

      print "\n";
      print "User: >>";
      db_user = STDIN.noecho(&:gets).strip;
      print "\n";
      print "Password: >>";
      db_pw   = STDIN.noecho(&:gets).strip;
      print "\n";
      conn = JDBCHelper::Connection.new(
       :driver           => @conf.get('prod_db_driver'),
       :url              => @conf.get('prod_db_url'),
       :user             => db_user,
       :password         => db_pw,
       :useCursorFetch   => 'true',
       :defaultFetchSize => 10000,
       );
      return conn;
    end
  end
end
