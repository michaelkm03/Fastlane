# coding: utf-8
require 'test_helper'
require 'vams/client'
require 'vams/submission_result'

module VAMS
  class VAMSAPISmokeTest < Minitest::Test
    def test_smokeit
      environment         = :dev
      test_app_build_name = 'dev-leachypeachy99'
      failure_message     = "VAMS Smoke API Test failed. This test hits real development VAMS api and it uses predefined data for #{test_app_build_name} app. Even though it might be an transient failure, if you see this failure consitently, it most likely means that aither VAMS api changed or VAMS has a problem itself. If this is the case, this needs to be addressed since we won't be able to submit apps in automated fashion 😕"

      with_webmock_disabled do
        client = Client.new(environment: environment)
        assert(client.apps_to_build, failure_message)

        app = client.app_by_build_name(test_app_build_name)
        assert(app, failure_message)

        result = SubmissionResult.new(app_id:   app.app_id,
                                      datetime: Time.now,
                                      status:   SubmissionResult::Status::GOOD,
                                      build:    'test build')
        assert(client.submit_result(result: result, environment: environment), failure_message)
      end
    end

    private

    def with_webmock_disabled
      ::WebMock.allow_net_connect!
      yield
      ::WebMock.disable_net_connect!
    end
  end
end
