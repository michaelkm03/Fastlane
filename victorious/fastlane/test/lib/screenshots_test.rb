require 'test_helper'
require 'vams/screenshots'
require 'fakefs/safe'

module VAMS
  class ScreenshotsTest < Minitest::Test
    def test_saving_screenshots
      FakeFS do
        screenshots_data = {
          en_US: [
            "https://s3.aws.amazon.com/victorious/en_US/1_screenshot.png",
            "https://s3.aws.amazon.com/victorious/en_US/2_screenshot.png"
          ]
        }
        screenshots = Screenshots.new(screenshots_data)
        location    = File.join(__dir__, '../tmp')
        screenshots.save(location: location)
        assert_equal(true, File.directory?(File.join(location, 'en_US')))
      end
    end
  end
end
