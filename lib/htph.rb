require 'htph/version';
require 'java';
require 'jdbc-helper';
require_relative '../ext/mysql-connector-java-5.1.17-bin.jar';
require_relative '../ext/sqlite-jdbc-3.8.6.jar';

require 'dotenv';
Dotenv.load();

module HTPH
  # When you:
  #   require 'htph';
  # ... then all the modules below get loaded and you can use them,
  # like so:
  #   HTPH::Hathienv::Env.is_prod?
end

# Require all the modules in lib/:
require 'htph/hathibench';
require 'htph/hathiconf';
require 'htph/hathidata';
require 'htph/hathidb';
require 'htph/hathienv';
require 'htph/hathijdbc';
require 'htph/hathilog';
require 'htph/hathinormalize';
