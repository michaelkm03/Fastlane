require 'test_helper'
require 'vams/client'
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
      stub_login(date: @date)
      received_token, user_id = @client.authenticate
      assert_equal(expected_token,   received_token)
      assert_equal(expected_user_id, user_id)
    end

    def test_retrieves_apps_to_build
      stub_login(date: @date)
      stub_apps_list(date: @date)
      apps      = @client.apps_to_build
      first_app = apps.first
      assert_equal(2,                apps.count)
      assert_equal("75",             first_app.app_id)
      assert_equal('Leachy Peachy',  first_app.app_name)
      assert_equal('leachypeachy',   first_app.build_name)
      assert_equal('unlocked',       first_app.app_state)
    end

    def test_gets_app_by_build_name
      stub_login(date: @date)
      stub_app_by_build_name(date: @date)
      build_name = 'LeachyPeachy'
      app = @client.app_by_build_name(build_name)
      assert_equal("75", app.app_id)
      assert_equal(1, app.ios_app_categories['Book'])
      assert_equal('com.getvictorious.${ProductPrefix}dev-leachypeachy99', app.bundle_id)
      assert_equal('com.getvictorious.dev-leachypeachy99',                 app.sanitized_bundle_id)
    end

    def test_gets_screenshots
      stub_login(date: @date)
      stub_screenshots(date: @date)
      build_name  = 'leachypeachy99'
      expected_en_screenshot_url = "http://s3.aws.amazon.com/victorious/en_US/1_screenshot.png"
      expected_es_screenshot_url = "http://s3.aws.amazon.com/victorious/es_ES/1_screenshot.png"
      screenshots = @client.get_screenshots(build_name)
      assert_equal(7,                          screenshots.en_US.count)
      assert_equal(expected_en_screenshot_url, screenshots.en_US[0])
      assert_equal(7,                          screenshots.es_ES.count)
      assert_equal(expected_es_screenshot_url, screenshots.es_ES[0])
    end

    def test_response_submission
      timestamp     = Time.parse("2015-03-10 01:39:34")
      result        = SubmissionResult.new(app_id: 1, status: 'All good', datetime: timestamp)
      response_code = 200
      stub_login(date: @date)
      stub_submit_result(status: response_code)
      response = @client.submit_result(result: result)
      assert_equal(response_code, response.code)

      response_code = 500
      stub_submit_result(status: response_code)
      assert_raises(SubmissionResult::FailedResponseError) {
        @client.submit_result(result: result)
      }
    end

    private

    def stub_login(environment: :staging, date:)
      env = Environment.construct(environment.to_sym)
      stub_request(:post, "https://#{environment.to_s}.getvictorious.com/api/login?email=#{env.username}&password=#{env.password}").
        with(:headers => {'Date'=> date.to_s, 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(::Payloads::SUCCESSFUL_LOGIN_PATH))
    end

    def stub_apps_list(environment: :staging, date:)
      stub_request(:get, "https://#{environment.to_s}.getvictorious.com/api/app/apps_list").
        with(:headers => {'Authorization'=>'BASIC 634159:80bc93519221902f41e16c5e32692868f2a7b7e7', 'Date'=>'2015-11-14 12:39:40 -0800', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(::Payloads::APPS_TO_BUILD_JSON_PATH), :headers => {})
    end

    def stub_app_by_build_name(environment: :staging, date:)
      stub_request(:get, "https://#{environment.to_s}.getvictorious.com/api/app/app_by_build_name/LeachyPeachy").
        with(:headers => {'Authorization'=>'BASIC 634159:9d946db398914a5525607026b4b4ed74c46704b8', 'Date'=>'2015-11-14 12:39:40 -0800', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(::Payloads::APP_BY_BUILD_NAME), :headers => {})
    end

    def stub_screenshots(environment: :staging, date:)
      stub_request(:get, "https://#{environment.to_s}.getvictorious.com/api/app/screenshots/leachypeachy99").
        with(:headers => {'Authorization'=>'BASIC 634159:0b1049c63b7a7b8a466af5d6668f7ce856f463c6', 'Date'=>'2015-11-14 12:39:40 -0800', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => 200, :body => File.read(::Payloads::SCREENSHOTS_PATH), :headers => {})
    end

    def stub_submit_result(status:)
      stub_request(:post, "https://staging.getvictorious.com/api/app/app_submission_response?app_id=1&build=3.4.2&datetime=2015-03-10%2001:39:34%20-0700&platform=iOS&status=All%20good").
        with(:headers => {'Authorization'=>'BASIC 634159:25f3c916048a9b545548a850337af0ea2075a4ed', 'Date'=>'2015-11-14 12:39:40 -0800', 'User-Agent'=>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:1 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'}).
        to_return(:status => status, :body => "", :headers => {})
    end
  end
end
