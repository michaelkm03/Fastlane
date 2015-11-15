require 'test_helper'
require 'vams/client'
require 'vams/payloads'
require 'vams/submission_result'

module VAMS
  class ClientTest < Minitest::Test
    def setup
      @date   = Time.parse('2015-11-14 12:39:40 -0800')
      @client = Client.new(environment: :staging, date: @date)
    end

    def test_authentication
      expected_token   = "token"
      expected_user_id = 634159
      stub_login(environment: :staging, date: @date)
      received_token, user_id = @client.authenticate
      assert_equal(expected_token,   received_token)
      assert_equal(expected_user_id, user_id)
    end

    def test_retrieves_apps_to_build
      stub_login(environment: :staging, date: @date)
      stub_apps_list(environment: :staging, date: @date)
      apps      = @client.apps_to_build
      first_app = apps.first
      assert_equal(2,                apps.count)
      assert_equal("75",             first_app.app_id)
      assert_equal('Leachy Peachy',  first_app.app_name)
      assert_equal('leachypeachy',   first_app.build_name)
      assert_equal('unlocked',       first_app.app_state)
    end

    def test_gets_app_by_build_name
      build_name = 'LeachyPeachy'
      app = @client.app_by_build_name(build_name)
      assert_equal("75", app.app_id)
      assert_equal(1, app.ios_app_categories['Books'])
      assert_equal('com.getvictorious.${ProductPrefix}leachypeachy', app.bundle_id)
    end

    def test_response_submission
      timestamp     = Time.parse("2015-03-10 01:39:34")
      result        = SubmissionResult.new(id: 1, status: 'All good', datetime: timestamp)
      response_code = 404
      stub_request(:post, 'https://staging.getvictorious.com/submission_result?body=%7B%22id%22:1,%22status%22:%22All%20good%22,%22datetime%22:%222015-03-10T01:39:34.000-07:00%22%7D').
        to_return(status: response_code, body: '')
      response = @client.submit_result(result: result, environment: :staging)
      assert_equal(response_code, response.code)
    end

    private

    def stub_login(environment:, date:)
      env = Environment.construct(environment.to_sym)
      stub_request(:post, "https://#{environment.to_s}.getvictorious.com/api/login?email=#{env.username}&password=#{env.password}").
        with(:headers => {'Date'=> date.to_s, 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(SUCCESSFUL_LOGIN_PATH))
    end

    def stub_apps_list(environment:, date:)
      stub_request(:get, "https://staging.getvictorious.com/api/app/apps_list").
        with(:headers => {'Authorization'=>'BASIC 634159:80bc93519221902f41e16c5e32692868f2a7b7e7', 'Date'=>'2015-11-14 12:39:40 -0800', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(APPS_TO_BUILD_JSON_PATH), :headers => {})
    end
  end
end
