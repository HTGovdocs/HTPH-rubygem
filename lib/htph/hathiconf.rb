=begin

Reads from configuration files and/or ENV as apropriate.
ENV gets read first, then the .env file, then the optional
conf_path.

If ENV contains hathiconf_file=xxx then file xxx will be used as a
conf file.

=end

require 'pathname';

module HTPH::Hathiconf
  class Conf

    @mem = {};

    def initialize(conf_path = nil)
      @mem = ENV;

      if !conf_path.nil? then
        read_conf(conf_path);
      end

      if ENV.has_key?('hathiconf_file') then
        read_conf(ENV['hathiconf_file']);
      end
    end

    def get(key)
      if @mem.has_key?(key) then
        return @mem[key];
      else
        STDERR.puts "Config could not find key #{key}";
        return '';
      end
    end

    # Like get() but less forgiving.
    def get!(key, message = '')
      val = get(key);
      if val == '' then
        raise "Could not find #{key}. #{message}";
      end
      return val;
    end

    def read_conf (path)
      cpath = Pathname.new(path).expand_path();
      if cpath.exist? then
        if cpath.readable? then
          cfile = File.open(cpath, 'r');
          cfile.each_line do |line|
            line.strip!;
            # Expect lines like:
            # db_user=mwarin2000
            # ... with any amount of spaces anywhere.
            # Ignore lines starting with #
            next if line.length == 0;
            next if line =~ /^\s*#/
            key, val = *line.scan(/^\s*([a-z_0-9]+)\s*=\s*(.+)\s*$/).flatten
            @mem[key] = val;
          end
          return true;
        else
          STDERR.puts "#{cpath} is not readable and cannot be used by #{__FILE__}";
        end
      else
        STDERR.puts "Config could not find file #{cpath}";
      end
      return false;
    end

  end
end
