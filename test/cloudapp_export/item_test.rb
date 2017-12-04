require "test_helper"

class CloudappExport::ItemTest < Minitest::Test
  def test_it_can_initialize
    item = ::CloudappExport::Item.new('name' => 'test')
    assert_equal item['name'], 'test'
  end
end
