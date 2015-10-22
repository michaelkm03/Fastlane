require 'test_helper'
require 'vams/client'

module VAMS
  class ClientTest < Minitest::Test
    def test_retrieves_apps_to_build
      apps = Client.apps_to_build
      first_app = apps.first
      assert_equal(5,         apps.count)
      assert_equal(1,         first_app.id)
      assert_equal('app one', first_app.name)
      assert_equal('AppOne',  first_app.build_name)
      assert_equal(false,     first_app.submit_for_review)
    end
  end
end
