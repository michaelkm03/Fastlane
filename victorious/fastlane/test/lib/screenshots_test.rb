require 'test_helper'
require 'vams/screenshots'
require 'fakefs/safe'

module VAMS
  class ScreenshotsTest < Minitest::Test
    def test_saving_screenshots
      fake_file_content = File.read(File.join(TEST_DIR_PATH, 'fixtures', 'screenshot.png'))
      stub_request(:get, "https://s3.aws.amazon.com/victorious/en_US/1_screenshot.png").
        to_return(:status => 200, :body => fake_file_content, :headers => {})

      FakeFS do
        screenshots_data = {
          en_US: [
            "https://s3.aws.amazon.com/victorious/en_US/1_screenshot.png",
          ]
        }
        screenshots = Screenshots.new(screenshots_data)
        location    = File.join(TEST_DIR_PATH, 'tmp')
        screenshots.save(location: location)
        assert(File.directory?(File.join(location, 'en_US')))
        assert(File.exists?(File.join(location, 'en_US/1_screenshot.png')))
      end
    end
  end
end
