require 'active_support/json'

module VAMS
  class SubmissionResult < Hash
    class FailedResponseError < RuntimeError
    end

    module Platform
      IOS = 'iOS'
    end

    module Status
      GOOD = 'App submission completed successfully'
      BAD  = 'App submission failed'
    end

    attr_reader :id,
                :status,
                :datetime,
                :platform

    def initialize(app_id:, status:, datetime:, platform: Platform::IOS, build: '3.4.2')
      self['app_id']   = app_id
      self['status']   = status
      self['datetime'] = datetime
      self['platform'] = platform
      self['build']    = build
    end
  end
end
