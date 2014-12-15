# A simple time benchmarking tool, intended to be used like so:

# require 'htph';
# b = HTPH::Hathibench::Benchmark.new();
# b.time("foo") do
#   some_lengthy_method();
# end
# puts b.prettyprint(); # Reports max, min, total, avg, etc.

# ... for benchmarking an arbitrary number of arbitrary code blocks.
# b.time() either takes a label, or if left blank, uses the caller
# path and line as label.

# Any number of labels can be timed, and each label can be used to
# time different things, if so wished.

module HTPH::Hathibench
  class Benchmark
    def initialize
      # Hash of Profile objects, keyed on their label.
      @profiles = {};
    end
    def time (label = caller(1)[0].split(':')[0,2].join(':'))
      # ^^ If no label given, use caller path + lineno. ^^
      @profiles[label] ||= Profile.new(label);
      ts = Time.new();
      yield;
      te = Time.new();
      # get duration as epoch-in-seconds.milliseconds
      duration = te.strftime("%s.%L").to_f - ts.strftime("%s.%L").to_f;
      @profiles[label].update(duration);
    end
    def prettyprint
      self.to_s; # Just an alias.
    end
    def to_s
      out = [%w[label time calls max min avg].join("\t")];
      @profiles.keys.sort.each do |label|
        out << @profiles[label].to_s;
      end
      return out.join("\n");
    end
  end

  # Benchmarking profile for a particular label.
  class Profile
    def initialize (label)
      @label = label;
      @time  = 0.0;
      @calls = 0;
      @max   = 0.0;
      @min   = Float::MAX;
    end
    def update (duration)
      @time  += duration;
      @calls += 1;
      @max    = duration if duration > @max;
      @min    = duration if duration < @min;
    end
    def to_s
      avg = 0;
      if @calls > 0 then
        avg = @time / @calls;
      end
      return [@label, @time, @calls, @max, @min, avg].join("\t");
    end
  end
end
