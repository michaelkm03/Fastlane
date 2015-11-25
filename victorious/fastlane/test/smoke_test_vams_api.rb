#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('lib')
require 'vams/client'
environment = :development
client = VAMS::Client.new(environment: environment)
puts '=== Getting apps to build'
puts client.apps_to_build
puts '=== Getting an app by build name'
app = client.app_by_build_name('leachypeachy')

require 'vams/submission_result'
result = VAMS::SubmissionResult.new(app_id: app.app_id, status: "App submission completed successfully", datetime: Time.now)
puts '=== Posting an app submission result'
puts 'Payload to submit: ' + result.to_json
puts client.submit_result(result: result, environment: environment)
