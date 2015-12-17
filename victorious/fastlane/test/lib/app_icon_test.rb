require 'test_helper'
require 'vams/app'
require 'vams/app_icon'

module VAMS
  class AppIconTest < Minitest::Test
    include FileTestHelper

    def setup
      clean_tmp_dir
    end

    def test_saving
      logo_filename   = 'logo_image_1024x1024.png'
      logo_url_string = "http:\/\/media-dev-public.s3-website-us-west-1.amazonaws.com\/_static\/assets\/75\/originals\/#{logo_filename}"
      fake_file_content = read_file(TEST_DIR_PATH, 'fixtures', logo_filename)
      app = App.new(original_logo_image: logo_url_string)

      stub_request(:get, logo_url_string).
        to_return(:status => 200, :body => fake_file_content, :headers => {})

      app_icon = AppIcon.new(app: app)
      location = TMP_DIR
      app_icon.save(location: location, filename: logo_filename)
      assert_equal(fake_file_content, read_file(location, logo_filename))
    end

    def teardown
      clean_tmp_dir
    end
  end
end
