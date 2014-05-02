require 'minitest_helper'

class TestHtph < MiniTest::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::HTPH::VERSION
  end
end
