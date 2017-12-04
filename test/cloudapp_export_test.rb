require "test_helper"

class CloudappExportTest < Minitest::Test
  def test_it_has_a_version_number
    assert_match %r(\A([0-9]+\.){1,2}[0-9]+\z), ::CloudappExport::VERSION
  end
end
