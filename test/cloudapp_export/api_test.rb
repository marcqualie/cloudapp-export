require "test_helper"

class CloudappExport::ApiTest < Minitest::Test
  def test_it_can_initialize
    api = ::CloudappExport::Item.new('username' => 'test@example.com')
    refute_nil api
  end
end
