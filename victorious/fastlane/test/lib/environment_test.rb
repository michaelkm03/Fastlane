require 'test_helper'
require 'vams/environment'

module VAMS
  class EnvironmentTest < Minitest::Test
    def test_valid_environments
      assert_raises(Environment::InvalidEnvironmentError) {
        Environment.construct(:some_environment_that_doesnt_exist)
      }
      assert(Environment.construct(:dev))
    end
  end
end
