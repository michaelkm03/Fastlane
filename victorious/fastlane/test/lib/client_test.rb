require 'test_helper'
require 'vams/client'

module VAMS
  class ClientTest < Minitest::Test
    def test_retrieves_apps_to_build
      apps = Client.apps_to_build
      first_app = apps.first
      assert_equal(2,               apps.count)
      assert_equal(1,               first_app.id)
      assert_equal('Leachy Peachy', first_app.name)
      assert_equal('LeachyPeachy',  first_app.build_name)
      assert_equal(false,           first_app.submit_for_review)
    end

    def test_gets_app_by_build_name
      build_name = 'LeachyPeachy'
      app = Client.app_by_build_name(build_name)
      assert_equal(11, app.app_id)
      assert_equal(1, app.payload['ios_app_categories']['Books'])
      assert_equal('com.getvictorious.${ProductPrefix}leachypeachy', app.payload['bundle_id'])
    end

    def test_response_submission
      timestamp = Time.parse("2015-03-10 01:39:34")
      result = SubmissionResult.new(id: 1, status: 'All good', datetime: timestamp)
      request_json = "{\"id\":1,\"status\":\"All good\",\"datetime\":\"2015-03-10T01:39:34.000-07:00\"}"
      response_code = 404
      stub_request(:post, 'https://example.com/submission_result').
        with(body: request_json).
        to_return(status: response_code, body: '')
      response = Client.submit_result(result)
      assert_equal(response_code, response.code)
    end
  end
end
