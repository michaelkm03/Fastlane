#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('lib')
require 'vams/client'
environment = :development
client = VAMS::Client.new(environment: environment)
puts client.apps_to_build
app = client.app_by_build_name('leachypeachy')
puts app
puts "ID:" + app.app_id

require 'vams/submission_result'
result = VAMS::SubmissionResult.new(id: app.app_id, status: "App submission completed successfully", datetime: Time.now)
puts result.to_json
puts client.submit_result(result: result, environment: environment)
