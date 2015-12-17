require 'minitest/autorun'
require 'minitest/rg'
require 'webmock/minitest'
Dir[File.join(__dir__, 'support/*.rb')].each { |support_file| require support_file }
$LOAD_PATH.unshift(__dir__ + '/../lib')
