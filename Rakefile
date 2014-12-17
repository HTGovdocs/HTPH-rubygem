require 'bundler/gem_tasks';
require 'rake/testtask';

# To run tests, do:
#   rake test hathiconf_file=<path_to_env_file>
# ... and HTPH::Hathiconf will pick up from there.

if !ENV.has_key?('hathiconf_file') then
  raise 'Put hathiconf_file=<path_to_env_file> at the end of the rake command.';
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test';
  t.test_files = FileList['test/unit.rb'];
end

task :default => :test;
