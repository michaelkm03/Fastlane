#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('lib')
require 'vams/client'
environment = :dev
client = VAMS::Client.new(environment: environment)
puts '=== Getting apps to build'
puts client.apps_to_build
puts '=== Getting an app by build name'
app = client.app_by_build_name('leachypeachy')

require 'vams/submission_result'
result = VAMS::SubmissionResult.new(app_id:   app.app_id,
                                    datetime: Time.now,
                                    status:   VAMS::SubmissionResult::Status::GOOD,
                                    build:    '3.5 (23123123)')
puts '=== Posting an app submission result'
puts 'Payload to submit: ' + result.to_json
puts client.submit_result(result: result, environment: environment)
