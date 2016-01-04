require 'test_helper'
require 'vams/colored_logger'

module VAMS
  class ColoredLoggerTest < Minitest::Test
    def test_color_errors
      stream = StringIO.new
      logger = ColoredLogger.new(stream)
      logger.error('oh noooo')
      stream.rewind
      expected_error_text = '\\e\[0\;37\;41moh\ noooo\\e\[0m'
      assert_match(/#{expected_error_text}/, stream.read)
    end
  end
end
