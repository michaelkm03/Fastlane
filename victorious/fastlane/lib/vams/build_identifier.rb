# coding: utf-8
module VAMS
  class BuildIdentifier
    class InvalidBuildError < RuntimeError
    end

    attr_reader :version, :build

    def initialize(version:, build:)
      if (!version && build) || (version && !build)
        raise InvalidBuildError.new("Build identifier requires both a version and a build. Here is what was passed in: Version: #{version}, Build: #{build} 🤔")
      end

      @version = version
      @build   = build
    end

    def to_s
      stringify
    end

    def inspect
      stringify
    end

    private

    def stringify
      @version && @build ? "Version: #{@version}, Build: #{@build}" : 'No build information available'
    end
  end
end
