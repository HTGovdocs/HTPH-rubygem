=begin
Example:

require 'htph/hathienv';

if HTPH::Hathienv::Env.is_dev? then
  puts "dev";
end

=end

module HTPH::Hathienv
  class Env    
    @@conf = HTPH::Hathiconf::Conf.new();
    def Env.is_dev? ()
      return %x(hostname).strip == @@conf.get('dev_host');
    end
    def Env.is_prod? ()
      return %x(hostname).strip == @@conf.get('prod_host');
    end
  end
end
