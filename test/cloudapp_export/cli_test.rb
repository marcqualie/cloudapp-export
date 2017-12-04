require "test_helper"

class CloudappExport::CliTest < Minitest::Test
  def test_it_inherits_from_thor
    assert ::CloudappExport::CLI < Thor
  end
end
