require 'test_helper'
require 'vams/client'
require 'vams/metadata'
require 'vams/app'

module VAMS
  class MetadataTest < Minitest::Test
    def test_extracts_metadata
      copyright              = 'Victorious Inc'
      ios_primary_category   = 'Entertainment'
      ios_secondary_category = 'Education'
      ios_description        = 'Teach me how to peachy'
      ios_keywords           = 'leachy,peachy,keywords'
      app_name               = 'Leachy Peachy'
      privacy_policy_url     = 'http://example.com/privacy_policy'
      support_url            = 'http://example.com/support'

      app = App.new({
        copyright:              copyright,
        ios_primary_category:   ios_primary_category,
        ios_secondary_category: ios_secondary_category,
        ios_description:        ios_description,
        ios_keywords:           ios_keywords,
        app_name:               app_name,
        privacy_policy_url:     privacy_policy_url,
        support_url:            support_url
      })

      metadata = Metadata.new(app)
      assert_equal(copyright,              metadata.copyright)
      assert_equal(ios_primary_category,   metadata.ios_primary_category)
      assert_equal(ios_secondary_category, metadata.ios_secondary_category)
      assert_equal(ios_description,        metadata.ios_description)
      assert_equal(ios_keywords,           metadata.ios_keywords)
      assert_equal(app_name,               metadata.app_name)
      assert_equal(privacy_policy_url,     metadata.privacy_policy_url)
      assert_equal(support_url,            metadata.support_url)
    end
  end
end
