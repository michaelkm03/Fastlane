require 'test_helper'
require 'vams/build_identifier'

module VAMS
  class BuildIdentifierTest < Minitest::Test
    def test_build_number_generation
      version = '3.5'
      build   = '10000'
      build_identifier = BuildIdentifier.new(version: version, build: build)
      assert_equal('Version: 3.5, Build: 10000', build_identifier.to_s)

      empty_build_identifier = BuildIdentifier.new(version: nil, build: nil)
      assert_equal('No build information available', empty_build_identifier.to_s)

      assert_raises(BuildIdentifier::InvalidBuildError) {
        BuildIdentifier.new(version: nil, build: build)
      }

      assert_raises(BuildIdentifier::InvalidBuildError) {
        BuildIdentifier.new(version: version, build: nil)
      }
    end
  end
end
