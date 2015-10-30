require 'test_helper'
require 'vams/client'
require 'vams/payloads'

module VAMS
  class ClientTest < Minitest::Test
    def test_authentication
      date           = Time.now
      expected_token = "token"
      stub_request(:get, "https://api.getvictorious.com/api/login?email=#{Client::DEFAULT_VAMS_USER}&password=#{Client::DEFAULT_VAMS_PASSWORD}").
        with(:headers => {'Date'=>date.to_s, 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:11 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(SUCCESSFUL_LOGIN_PATH))

      received_token = Client.authenticate(date: date)
      assert_equal(expected_token, received_token)
    end

    def test_retrieves_apps_to_build
      apps = Client.apps_to_build
      first_app = apps.first
      assert_equal(2,                apps.count)
      assert_equal(1,                first_app.id)
      assert_equal('Leachy Peachy',  first_app.name)
      assert_equal('LeachyPeachy99', first_app.build_name)
      assert_equal(false,            first_app.submit_for_review)
    end

    def test_gets_app_by_build_name
      build_name = 'LeachyPeachy'
      app = Client.app_by_build_name(build_name)
      assert_equal("75", app.app_id)
      assert_equal(1, app.ios_app_categories['Books'])
      assert_equal('com.getvictorious.${ProductPrefix}leachypeachy', app.bundle_id)
    end

    def test_response_submission
      timestamp     = Time.parse("2015-03-10 01:39:34")
      result        = SubmissionResult.new(id: 1, status: 'All good', datetime: timestamp)
      response_code = 404
      stub_request(:post, 'https://api.getvictorious.com/submission_result?body=%7B%22id%22:1,%22status%22:%22All%20good%22,%22datetime%22:%222015-03-10T01:39:34.000-07:00%22%7D').
        to_return(status: response_code, body: '')
      response = Client.submit_result(result)
      assert_equal(response_code, response.code)
    end
  end
end
