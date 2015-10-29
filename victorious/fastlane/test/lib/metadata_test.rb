require 'test_helper'
require 'vams/metadata'
require 'vams/payloads'
require 'vams/app'

module VAMS
  class MetadataTest < Minitest::Test
    def test_extracts_metadata
      json     = JSON.parse(File.read(APP_BY_BUILD_NAME))
      app      = App.new(json)
      metadata = Metadata.new(app)

      assert_equal(nil, metadata.copyright)
      assert_equal(nil, metadata.ios_primary_category)
      assert_equal(nil, metadata.ios_secondary_category)
      assert_equal(nil, metadata.ios_description)
      assert_equal(nil, metadata.ios_keywords)
      assert_equal(nil, metadata.app_name)
      assert_equal(nil, metadata.privacy_policy_url)
      assert_equal(nil, metadata.support_url)
    end
  end
end
