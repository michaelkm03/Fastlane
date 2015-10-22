require 'test_helper'
puts $LOAD_PATH
require 'vams/client'

module VAMS
  class ClientTest < Minitest::Test
    def test_retrieves_apps_to_build
      assert_equal(5, Client.apps_to_build.count)
    end
  end
end
