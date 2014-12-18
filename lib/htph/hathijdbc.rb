require 'java';
require 'io/console';
require 'htph/hathiconf';
require 'htph/hathienv';

=begin

When you can't, for some reason, use HTPH::Hathidb, e.g. when
you are in Sinatra-land, you can use this for database connections.
Does not use JDBC-Helper.

Example:

db      = HTPH::Hathijdbc::Jdbc.new();
conn    = db.get_conn();
sel_sql = "SELECT x FROM table_y WHERE z = ? AND q = ?";
conn.prepared_select(sel_sql, ['aa', 'bb']) do |row|
  puts row.get_object('x');
end

upd_sql = "UPDATE table_y SET z = ? WHERE z = ?";
success = conn.prepared_update(upd_q, [new_val, old_val]);

N.B.: prepared_update can do UPDATE, INSERT, DELETE,
LOAD DATA LOCAL INFILE ...

=end

module HTPH::Hathijdbc
  class Jdbc

    def initialize ()
      @conf = HTPH::Hathiconf::Conf.new();
    end

    def get_conn
      driver = Java::com.mysql.jdbc.Driver.new;
      props  = java.util.Properties.new;
      props.setProperty("user", @conf.get('db_user'));
      props.setProperty("password", @conf.get('db_pw'));
      url    = @conf.get('db_url');

      return HTPH::Hathijdbc::Conn.new(driver, url, props);
    end
  end

  class Conn
    def initialize (driver, url, props)
      @driver = driver;
      @url    = url;
      @props  = props;
      @conn   = driver.connect(url, props);
      @prep_cache = {};

      return self;
    end

    def close
      @conn.close
    end

    def get_prepared_statement (sql, bind_params)
      pstatement = nil;
      if @prep_cache.has_key?(sql) then
        pstatement = @prep_cache[sql];
      else
        pstatement = @conn.prepare_statement(sql);
        @prep_cache[sql] = pstatement;
      end

      if pstatement.nil? then
        raise "wha"
      end

      # Set bind_params according to their class (add more classes if needed)
      bind_params.each_with_index do |e,i|
        j = i+1; # This index starts with 1.
        if e.class.ancestors.include?(Integer) then
          pstatement.set_long(j, e);
        elsif e.class == Java::JavaMath::BigDecimal then
          pstatement.set_big_decimal(j, e);
        elsif e.class == Float then
          pstatement.set_float(j, e);
        elsif e.class == String then
          pstatement.set_string(j, e);
        else
          raise "Don't know what to set #{e} (#{e.class}) as";
        end
      end

      return pstatement;
    end

    # Use like so, where params is an optional array with values for bind-params:
    # prepared_select("SELECT 1 AS c", params) do |row|
    #   puts row.get_object('c')
    # end
    def prepared_select (sql, bind_params = [])
      pstatement = self.get_prepared_statement(sql, bind_params);
      qok = pstatement.execute();
      if qok == true then
        rs = pstatement.getResultSet();
        while (rs.next) do
          yield rs;
        end
      else
        yield nil;
      end
    end

    def prepared_update (sql, bind_params = [])
      pstatement = self.get_prepared_statement(sql, bind_params);
      # pstatement.execute_update supposedly returns number of affected rows, so 0 would be a fail.
      affected = pstatement.execute_update();

      return affected == 0 ? false : true;
    end

    # Takes a select-query without bind params. Yields resulting rows.
    # Use like so:
    # simple_select("select 1 as c") do |row|
    #   puts row.get_object('c');
    # end
    def simple_select (sql)
      # Java::ComMysqlJdbc::StatementImpl,
      # http://www.docjar.com/docs/api/com/mysql/jdbc/StatementImpl.html
      statement = @conn.create_statement();
      # Java::ComMysqlJdbc::JDBC4ResultSet
      rs = statement.execute_query(sql);
      while (rs.next) do
        yield rs;
      end
    ensure
      statement.close;
    end

    def prepare_qmarks (sql, bindparams)
      s = bindparams.size;
      q = sql.sub('__?__', (['?'] * s).join(','));
      return q;
    end

  end
end
