require 'test_helper'
require 'vams/submission_result'

module VAMS
  class SubmissionResultTest < Minitest::Test
    def setup
      timestamp = Time.parse("2015-03-10 01:39:34")
      @result   = SubmissionResult.new(id: 1, status: 'All good', datetime: timestamp)
      @request_json = "{\"id\":1,\"status\":\"All good\",\"datetime\":\"2015-03-10T01:39:34.000-07:00\",\"platform\":\"iOS\"}"
    end

    def test_json_payload
      json_payload = @result.to_json
      assert_equal(@request_json, json_payload)
    end
  end
end
