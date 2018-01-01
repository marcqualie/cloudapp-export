require "test_helper"

class CloudappExport::ExporterTest < Minitest::Test
  def test_it_can_initialize
    items = []
    exporter = ::CloudappExport::Exporter.new(items)
    assert exporter.respond_to?(:export_all)
  end
end
