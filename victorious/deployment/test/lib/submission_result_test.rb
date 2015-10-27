require 'test_helper'
require 'vams/submission_result'

module VAMS
  class SubmissionResultTest < Minitest::Test
    def test_response_json
      timestamp = Time.parse("2015-03-10 01:39:34")
      result    = SubmissionResult.new(id: 1, status: 'All good', datetime: timestamp)
      response_json = result.to_json
      assert_equal('{"id":1,"status":"All good","datetime":"2015-03-10T01:39:34.000-07:00"}', response_json)
    end
  end
end
