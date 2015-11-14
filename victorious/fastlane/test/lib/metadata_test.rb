require 'test_helper'
require 'vams/client'
require 'vams/metadata'
require 'vams/payloads'
require 'vams/app'

module VAMS
  class MetadataTest < Minitest::Test
    def test_extracts_metadata
      client   = Client.new
      app      = client.app_by_build_name('LeachyPeachy')
      metadata = Metadata.new(app)

      assert_equal('Victorious Inc',                    metadata.copyright)
      assert_equal('Entertainment',                     metadata.ios_primary_category)
      assert_equal('Education',                         metadata.ios_secondary_category)
      assert_equal('Teach me how to peachy',            metadata.ios_description)
      assert_equal('leachy,peachy,keywords',            metadata.ios_keywords)
      assert_equal('Leachy Peachy',                     metadata.app_name)
      assert_equal('http://example.com/privacy_policy', metadata.privacy_policy_url)
      assert_equal('http://example.com/support',        metadata.support_url)
    end
  end
end
