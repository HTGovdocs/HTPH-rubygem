=begin

Uniform access to data files across scripts. All methods should
return self. .file is readable to the outside.

Open and close, inflate and deflate, all as long as you keep track
of where they are inside the data directory, outside which this
module should not dare wander.

=end

require 'pathname';
require 'zlib';
require 'htph/hathilog';
require 'htph/hathiconf';

module HTPH::Hathidata

  # More in tune with the ruby way, hiding the open and close.
  
  # HTPH::Hathidata.write('foo') do |x|
  #   x.file.puts 'hello';
  #   x.file.puts 'adieu';
  # end
  def self.write(path, mode = 'w', &block)
    hd = Data.new(path).open(mode);
    hd.instance_eval(&block);
  ensure
    hd.close();
  end

  # HTPH::Hathidata.read('foo') do |line|
  #   puts line; # --> prints "hello\nadieu\n"
  # end
  # Break the loop with:
  #   throw :break;
  def self.read(path)
    hd = Data.new(path).open('r');
    catch :break do
      hd.file.each_line do |line|
        yield line;
      end
    end
  ensure
    hd.close();
  end

  class Data

    @@log  = HTPH::Hathilog::Log.new();
    @@conf = HTPH::Hathiconf::Conf.new();

    attr_reader :path;
    attr_reader :file;
    attr_reader :data_dir_path;

    def initialize(p_path)
      # Make sure data dir path is set in .env, and set to
      # a readable and writable path.      
      @data_dir_path = Pathname.new(@@conf.get!('data_dir_path', "Please set in your .env"));
      if !File.readable?(@data_dir_path) then
        raise "HTPH::Hathidata::Data::@data_dir_path #{@data_dir_path} must be readable";
      end
      if !File.writable?(@data_dir_path) then
        raise "HTPH::Hathidata::Data::@data_dir_path #{@data_dir_path} must be writable";
      end
      
      # Make it possible to easily date filenames.
      # Inlude $ymd and get it replaced with yyyymmdd.
      # Works on both filenames and dirs
      if p_path[/\$ymd/] then
        ymd = Time.new().strftime("%Y%m%d");
        p_path.gsub!(/\$ymd/, ymd);
      end

      @path = @data_dir_path + p_path; # Pathname. Do not be fooled.
    end

    # Files are opened as r if not otherwise specified.
    # A HTPH::Hathidata::Data obj only holds 1 file at a time.
    # Path is created if parts of it is missing.
    def open(p_attr = 'r')
      @@log.d("Open #{@path} as #{p_attr}");
      if !@path.exist? then
        if p_attr == 'r' then
          raise "Cannot open #{@path} for reading, path does not exist.";
        end
        @path.descend do |v|
          if !v.exist? && v != @path then
            # We need to make #{v}
            Dir.mkdir(v.to_s);
          end
        end
      end

      @file = File.open(@path, p_attr);

      self;
    end

    # If there is a backup, then open it.
    # Otherwise just open.
    def get_backup_or_open(p_attr = 'r')
      if self.backup? then
        @path = self.backup_path();
        return self.inflate().open(p_attr);
      end
      self.open(p_attr);
    end

    # Closes the open file.
    def close
      if @file != nil then
        if !@file.closed? then
          @file.close();
          @@log.d("Closing #{@path}");
        else
          @@log.w("Cannot close #{@path} because already closed.");
        end
      else
        @@log.w("Cannot close #{@path} because not open.");
      end

      self;
    end

    def exists?
      File.exists?(@path);
    end

    def backup_path
      @path.to_s + '.gz';
    end

    def backup?
      File.exists?(self.backup_path());
    end

    # If you just want to make sure it is there.
    # Will truncate previous contents, if any.
    def touch
      @@log.d("Touch #{@path}");
      self.open('w').close();
    end

    # If you want to touch it without truncating it.
    def gentle_touch
      @@log.d("Gentle touch #{@path}");
      if !self.exists?(@path) then
        self.open('w').close();
      end
    end

    def delete
      self.close();
      @@log.d("Deleting #{@path}");
      if self.exists? then
        File.delete(@path);
      end
      self;
    end

    # Compress, gzip.
    # Deletes the original.
    # Switches @path after deflate.
    def deflate
      zipped_fn = @path.to_s + '.gz';
      @@log.d("deflate #{@path} to #{zipped_fn}");
      gz_writer  = Zlib::GzipWriter.open(zipped_fn);
      File.open(@path, 'r').each do |line|
        gz_writer.write(line);
      end
      gz_writer.close();
      @@log.d("Deleting #{@path}");
      File.delete(@path);
      @path = Pathname.new(zipped_fn);
      @@log.d("New path #{@path}");

      self;
    end

    # Decompress, gunzip.
    # Deletes the original.
    # Switches @path after inflate.
    def inflate
      if @path.to_s =~ /\.gz$/ then
        unzipped_fn = @path.to_s.gsub(/\.gz$/, '');
        unzipped_f  = File.open(unzipped_fn, 'w');
        @@log.d("inflate #{@path} to #{unzipped_fn}");
        Zlib::GzipReader.open(@path) do |gzr|
          gzr.each_line do |line|
            unzipped_f.write(line);
          end
        end
        unzipped_f.close();
        @@log.d("Deleting #{@path}");
        File.delete(@path);
        @path = Pathname.new(unzipped_fn);
        @@log.d("New path #{@path}");
      else
        STDERR.puts "#{@path} not a .gz file.";
      end

      self;
    end

  end
end
