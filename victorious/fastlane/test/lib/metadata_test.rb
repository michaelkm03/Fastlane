require 'test_helper'
require 'vams/client'
require 'vams/metadata'
require 'vams/app'

module VAMS
  class MetadataTest < Minitest::Test
    def setup
      @tmp_dir = File.join(TEST_DIR_PATH, 'tmp')
      clean_tmp_dir
      @copyright              = 'Victorious Inc'
      @ios_primary_category   = 'Entertainment'
      @ios_secondary_category = 'Education'
      @ios_description        = 'Teach me how to peachy'
      @ios_keywords           = 'leachy,peachy,keywords'
      @app_name               = 'Leachy Peachy'
      @privacy_policy_url     = 'http://example.com/privacy_policy'
      @support_url            = 'http://example.com/support'

      app = App.new({
        copyright:              @copyright,
        ios_primary_category:   @ios_primary_category,
        ios_secondary_category: @ios_secondary_category,
        ios_description:        @ios_description,
        ios_keywords:           @ios_keywords,
        app_name:               @app_name,
        privacy_policy_url:     @privacy_policy_url,
        support_url:            @support_url
      })

      @metadata = Metadata.new(app)
    end

    def test_saving
      location = @tmp_dir
      @metadata.save(location: location)
      assert_file_exists(location, 'copyright.txt')
      assert_file_exists(location, 'secondary_category.txt')
    end

    def teardown
      clean_tmp_dir
    end

    private

    def assert_file_exists(*paths)
      file_location = File.join(paths)
      assert(File.exists?(file_location))
    end

    def clean_tmp_dir
      FileUtils.rm_rf(Dir["#{@tmp_dir.to_s}/*.txt"])
    end
  end
end
