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
      @ios_primary_category   = '5'
      @ios_secondary_category = '4'
      @ios_description        = 'Teach me how to peachy'
      @ios_keywords           = 'leachy,peachy,keywords'
      @app_name               = 'Leachy Peachy'
      @privacy_policy_url     = 'http://example.com/privacy_policy'
      @support_url            = 'http://example.com/support'
      @ios_app_categories     = {
        "Books"             => 1,
        "Business"          => 2,
        "Catalogs"          => 3,
        "Education"         => 4,
        "Entertainment"     => 5,
        "Finance"           => 6,
        "Food & Drink"      => 7,
        "Games"             => 8,
        "Health & Fitness"  => 9,
        "Lifestyle"         => 10,
        "Medical"           => 11,
        "Music"             => 12,
        "Navigation"        => 13,
        "News"              => 14,
        "Photo & Video"     => 15,
        "Productivity"      => 16,
        "Reference"         => 17,
        "Social Networking" => 18,
        "Sports"            => 19,
        "Travel"            => 20,
        "Weather"           => 21
      }


      @app = App.new({
                      ios_app_categories:     @ios_app_categories,
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
      location = @tmp_dir
      language = 'en_US'
      @metadata.save(location: location, language: language)
      assert_equal(@copyright,          read_file(location, 'copyright.txt'))
      assert_equal('Entertainment',     read_file(location, 'primary_category.txt'))
      assert_equal('Education',         read_file(location, 'secondary_category.txt'))
      assert_equal(@ios_description,    read_file(location, language, 'description.txt'))
      assert_equal(@ios_keywords,       read_file(location, language, 'keywords.txt'))
      assert_equal(@privacy_policy_url, read_file(location, language, 'privacy_url.txt'))
      assert_equal(@support_url,        read_file(location, language, 'support_url.txt'))
      assert_equal(@app_name,           read_file(location, language, 'name.txt'))
    end

    def test_categories
      location                  = @tmp_dir
      language                  = 'en_US'
      setup_and_save_metadata(category: 9, location: location, language: language)
      assert_equal('Healthcare_Fitness', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: 3, location: location, language: language)
      assert_equal('Apps.Catalogs', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: 7, location: location, language: language)
      assert_equal('Apps.Food_Drink', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: 15, location: location, language: language)
      assert_equal('Photography', read_file(location, 'primary_category.txt'))

      setup_and_save_metadata(category: 18, location: location, language: language)
      assert_equal('SocialNetworking', read_file(location, 'primary_category.txt'))
    end

    def teardown
      clean_tmp_dir
    end

    private

    def setup_and_save_metadata(category:, location:, language:)
      clean_tmp_dir
      @app.ios_primary_category = category
      metadata                 = Metadata.new(@app)
      metadata.save(location: location, language: language)
    end

    def read_file(*paths)
      File.read(File.join(paths))
    end

    def assert_file_exists(*paths)
      file_location = File.join(paths)
      assert(File.exists?(file_location))
    end

    def clean_tmp_dir
      FileUtils.rm_rf(Dir["#{@tmp_dir.to_s}/*"])
    end
  end
end
