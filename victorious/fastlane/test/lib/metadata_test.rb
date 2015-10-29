require 'test_helper'
require 'vams/client'
require 'vams/metadata'
require 'vams/payloads'
require 'vams/app'

module VAMS
  class MetadataTest < Minitest::Test
    def test_extracts_metadata
      app      = Client.app_by_build_name('LeachyPeachy')
      metadata = Metadata.new(app)

      assert_equal(nil,                      metadata.copyright)
      assert_equal(nil,                      metadata.ios_primary_category)
      assert_equal(nil,                      metadata.ios_secondary_category)
      assert_equal('Teach me how to peachy', metadata.ios_description)
      assert_equal(nil,                      metadata.ios_keywords)
      assert_equal('Leachy Peachy',          metadata.app_name)
      assert_equal(nil,                      metadata.privacy_policy_url)
      assert_equal(nil,                      metadata.support_url)
    end
  end
end
