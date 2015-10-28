require 'test_helper'
require 'vams/submission_result'

module VAMS
  class SubmissionResultTest < Minitest::Test
    def setup
      timestamp = Time.parse("2015-03-10 01:39:34")
      @result   = SubmissionResult.new(id: 1, status: 'All good', datetime: timestamp)
      @request_json = "{\"id\":1,\"status\":\"All good\",\"datetime\":\"2015-03-10T01:39:34.000-07:00\"}"
    end

    def test_json_payload
      json_payload = @result.to_json
      assert_equal(@request_json, json_payload)
    end

    def test_response_submission
      response_code = 404
      stub_request(:post, 'http://example.com/submission_result').
        with(body: @request_json).
        to_return(status: response_code, body: '')
      response = @result.submit
      assert_equal(response_code, response.code)
    end
  end
end
