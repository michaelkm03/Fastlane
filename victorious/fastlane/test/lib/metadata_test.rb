require 'test_helper'
require 'vams/client'
require 'vams/metadata'
require 'vams/app'

module VAMS
  class MetadataTest < Minitest::Test
    include FileTestHelper

    def setup
      clean_tmp_dir
      @copyright              = 'Victorious Inc'
      @ios_primary_category   = {'Apps.Food_Drink':    7}
      @ios_secondary_category = {'Healthcare_Fitness': 9}
      @ios_description        = 'Teach me how to peachy'
      @ios_keywords           = 'leachy,peachy,keywords'
      @app_name               = 'Leachy Peachy'
      @privacy_policy_url     = 'http://example.com/privacy_policy'
      @support_url            = 'http://example.com/support'
      @app = App.new({
                       copyright:              @copyright,
                       ios_primary_category:   @ios_primary_category,
                       ios_secondary_category: @ios_secondary_category,
                       ios_description:        @ios_description,
                       ios_keywords:           @ios_keywords,
                       app_name:               @app_name,
                       privacy_policy_url:     @privacy_policy_url,
                       support_url:            @support_url
                     })

      @metadata = Metadata.new(@app)
    end

    def test_saving
      location = TMP_DIR
      language = 'en_US'
      @metadata.save(location: location, language: language)
      assert_equal(@copyright,           read_file(location, 'copyright.txt'))
      assert_equal('Apps.Food_Drink',    read_file(location, 'primary_category.txt'))
      assert_equal('Healthcare_Fitness', read_file(location, 'secondary_category.txt'))
      assert_equal(@ios_description,     read_file(location, language, 'description.txt'))
      assert_equal(@ios_keywords,        read_file(location, language, 'keywords.txt'))
      assert_equal(@privacy_policy_url,  read_file(location, language, 'privacy_url.txt'))
      assert_equal(@support_url,         read_file(location, language, 'support_url.txt'))
      assert_equal(@app_name,            read_file(location, language, 'name.txt'))
    end

    def test_categories
      location = TMP_DIR
      language = 'en_US'
      setup_and_save_metadata(category: {'Healthcare_Fitness': 9}, location: location, language: language)
      assert_equal('Healthcare_Fitness', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: {'Apps.Catalogs': 3}, location: location, language: language)
      assert_equal('Apps.Catalogs', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: {'Apps.Food_Drink': 7}, location: location, language: language)
      assert_equal('Apps.Food_Drink', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: {'Photography': 8}, location: location, language: language)
      assert_equal('Photography', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: {'SocialNetworking': 8}, location: location, language: language)
      assert_equal('SocialNetworking', read_file(location, 'primary_category.txt'))
    end

    def teardown
      clean_tmp_dir
    end

    private

    def setup_and_save_metadata(category:, location:, language:)
      clean_tmp_dir
      @app.ios_primary_category = category
      metadata                  = Metadata.new(@app)
      metadata.save(location: location, language: language)
    end
  end
end
