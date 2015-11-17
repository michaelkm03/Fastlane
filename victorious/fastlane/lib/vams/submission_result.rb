require 'active_support/json'

module VAMS
  class SubmissionResult < Hash
    module Platform
      IOS = 'iOS'
    end

    attr_reader :id,
                :status,
                :datetime,
                :platform

    def initialize(id:, status:, datetime:, platform: Platform::IOS)
      self['id']       = id
      self['status']   = status
      self['datetime'] = datetime
      self['platform'] = platform
    end
  end
end
