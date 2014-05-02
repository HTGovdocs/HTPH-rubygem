=begin
Example:

require 'htph/hathienv';

if HTPH::Hathienv::Env.is_dev? then
  puts "dev";
end

=end

module HTPH::Hathienv
  class Env
    def Env.is_dev? ()
      return !Env.is_prod?()
    end
    def Env.is_prod? ()
      return %x(hostname).include?('grog');
    end
  end
end
