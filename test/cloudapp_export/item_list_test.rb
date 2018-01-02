require "test_helper"

class CloudappExport::ItemListTest < Minitest::Test
  def test_it_can_initialize
    item_list = ::CloudappExport::ItemList.new(nil)
    refute_nil item_list
  end
end
