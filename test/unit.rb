require 'pathname';
require 'test/unit';

require 'htph';

class HathiUnit < Test::Unit::TestCase
  
  def self.scrub_scrub_scrub
    # Squeaky clean.
    puts "scrub scrub scrub";

    if File.exists?('/tmp/mwruby.log') then
      File.delete('/tmp/mwruby.log');
    end

    # Delete files in the log dir.
    logdir  = HTPH::Hathilog::Log.get_log_dir_path();
    %W<default.log levels.log>.each do |logfn|
      logpath = logdir.to_s + '/' + logfn;
      if File.exists?(logpath) then
        File.delete(logpath);
      end
    end
   
    %W<appendable bunny toad hasbackup.gz unittest/fox unittest/touche>.each do |hdfn|
      hd = HTPH::Hathidata::Data.new(hdfn);
      puts "Deleting #{hd.path}";
      hd.delete();
    end
  end

  def self.startup
    scrub_scrub_scrub();
  end

  def self.shutdown
    scrub_scrub_scrub();
  end

  # hathiconf
  def test_conf_keys()
    hc = HTPH::Hathiconf::Conf.new();
    assert_equal('', hc.get('does_not_exist'));
    assert_not_equal('', hc.get('db_user'));
  end

  # hathidb
  def test_db_simple_select
    db = HTPH::Hathidb::Db.new();
    c = db.get_conn();
    q = "SELECT 5 AS five";
    c.query(q) do |r|
      assert_equal(5, r[:five].to_i);
    end
    c.close();
  end

  # hathilog
  def test_log_simple
    lg = HTPH::Hathilog::Log.new();
    lg.d("lala");
    lg.i("ok");
    lg.w("umm");
    lg.e("eeeeeeeh");
    lg.f("splat");
    lg.close();    

    assert_equal(1, 1);
  end

  def test_log_to_filepath
    logpath = '/tmp/mwruby.log';
    assert_equal(false, Pathname.new(logpath).exist?());

    lg = HTPH::Hathilog::Log.new({:file_path => logpath});
    lg.d("lala");
    lg.i("ok");
    lg.w("umm");
    lg.e("eeeeeeeh");
    lg.f("splat");
    lg.close();

    assert_equal(true, Pathname.new(logpath).exist?());
  end

  def test_log_to_filename
    logdir  = HTPH::Hathilog::Log.get_log_dir_path();
    logpath = logdir.to_s + '/default.log';
    assert_equal(false, Pathname.new(logpath).exist?(), "What, #{logpath} should not exist yet.");

    lg = HTPH::Hathilog::Log.new({:file_name => 'default.log'});
    lg.d("lala");
    lg.i("ok");
    lg.w("umm");
    lg.e("eeeeeeeh");
    lg.f("splat");
    lg.close();

    assert_equal(true, Pathname.new(logpath).exist?());
  end

  def test_log_dated_filename
    assert_nothing_raised do
      lg = HTPH::Hathilog::Log.new({:file_name => 'dated.$ymd.log'});
      lg.d("Today!");
      logfile_path = lg.file_path;
      lg.close();

      assert_equal(true, Pathname.new(logfile_path).exist?());
      File.delete(logfile_path);
    end
  end

  def test_level_log

    lg = HTPH::Hathilog::Log.new({:log_level => 3, :file_name => 'levels.log'});

    lg.d("no debug");
    lg.i("no info");
    lg.w("no warn");
    lg.e("yes error");
    lg.f("yes fatal");

    lg.set_level(1);
    lg.d("no debug");
    lg.i("yes info");

    lg.close();
    line_count = 0;

    f = File.open(lg.file_path, 'r');
      f.each_line do |line|
        line_count += 1;
      end
    f.close();

    assert_equal(3, line_count);
  end

  ## hathidata
  def test_data_read_write
    # Part 1
    hd = HTPH::Hathidata::Data.new('bunny')
    assert_equal(false, hd.exists?());
    hd.open('w');
    hd.file.puts "FOO time #{Time.new()}";
    hd.file.flush();
    hd.close();
    assert_equal(true, hd.exists?());
    assert_equal(true, hd.file.closed?());

    # Part 2
    hd2 = HTPH::Hathidata::Data.new('bunny');
    assert_equal(true, hd2.exists?(), "#{hd2.path} does not exist?");

    hd2.open.file.each_line do |line|
      assert_match(/FOO time/, line);
      break;
    end
    hd2.close();
  end

  def test_data_deflate
    # Part 1
    hd = HTPH::Hathidata::Data.new('toad');
    assert_equal(false, hd.exists?());
    hd.open('w').file.puts "Ribbit #{Time.new()}";
    hd.close();
    hd.deflate();
    assert_equal(true, hd.exists?());

    # Part 2
    hd2 = HTPH::Hathidata::Data.new('toad.gz');
    assert_equal(true, hd2.exists?());
    hd2.inflate.open.file.each_line do |line|
      puts "inflate_file: #{line}";
    end
    hd2.close();
    assert_equal(true, hd2.exists?());
  end

  def test_data_close_unopened
    assert_nothing_raised do
      hd = HTPH::Hathidata::Data.new('froofroo');
      hd.close();
    end
  end

  def test_data_ymd_in_filename
    assert_nothing_raised do
      hd = HTPH::Hathidata::Data.new('unittest/dated.$ymd.txt').open('w');
      hd.file.puts("Today!");
      hd.close();
      hd.delete();
    end
  end

  def test_data_ymd_in_dirname
    assert_nothing_raised do
      hd = HTPH::Hathidata::Data.new('unittest/$ymd/dated.txt').open('w');
      hd.file.puts("Today!");
      hd.close();
      parent_dir = hd.path.parent();
      hd.delete();
      Dir.rmdir(parent_dir);
    end
  end

  def test_data_full_circle
    # We make sure path is created all the way.
    hd = HTPH::Hathidata::Data.new('unittest/fox');
    assert_equal(false, hd.exists?());
    hd.open('w').file.puts "BARK BARK";
    hd.close();
    assert_equal(true, hd.exists?());
    hd.deflate();
    assert_equal(true, hd.exists?());

    # Make sure we can read from inflated file.
    hd2 = HTPH::Hathidata::Data.new('unittest/fox.gz');
    assert_equal(true, hd2.exists?());
    hd2.inflate.open.file.each_line do |line|
      assert_match(/BARK/, line);
    end
    hd2.close();
  end

  def test_data_touch
    t = HTPH::Hathidata::Data.new('unittest/touche')
    assert_equal(false, t.exists?());
    t.touch();
    assert_equal(true, t.exists?());
  end

  def test_data_append
    # Part 1
    app = HTPH::Hathidata::Data.new('appendable')
    assert_equal(false, app.exists?());
    app.open('w').file.puts "1";
    app.close();

    # Part 2
    assert_equal(true, app.exists?());
    app.open('a').file.puts "2";
    app.close();

    # Part 3
    sum = 0;
    app.open('r').file.each_line do |line|
      sum += line.strip.to_i;
    end
    app.close();
    assert_equal(3, sum);
  end

  def test_data_exists
    hd = HTPH::Hathidata::Data.new('doesnotexist');
    assert_equal(false, hd.exists?);
    hd.touch();
    assert_equal(true, hd.exists?);
    hd.delete;
    assert_equal(false, hd.exists?);
  end

  def test_data_backup
    hd = HTPH::Hathidata::Data.new('hasnobackup');
    assert_equal(false, hd.exists?);
    assert_equal(false, hd.backup?);

    # Create a backup file for 'hasbackup'
    HTPH::Hathidata::Data.new('hasbackup').touch().deflate();
    hd2 = HTPH::Hathidata::Data.new('hasbackup');

    assert_equal(false, hd2.exists?);
    assert_equal(true, hd2.backup?);

    hd2.get_backup_or_open('w');
    assert_equal(true, hd2.exists?);
    hd2.file.puts Time.new().to_s;
    hd2.close().deflate();
  end

  def test_data_writer_reader
    t = Time.new().to_s;
    testfile = 'unittest/by_writer';
    HTPH::Hathidata.write(testfile) do |hd|
      hd.file.puts t;
    end

    HTPH::Hathidata.read(testfile) do |line|
      assert_equal(line.strip, t);
    end

    HTPH::Hathidata::Data.new(testfile).delete;
  end

  def test_query
    assert_equal(true, HTPH::Hathiquery.source_map.has_key?('MIU'));
    assert_equal(true, HTPH::Hathiquery.cali_members.include?('ucla'));
  end

end
