require 'active_support/json'

module VAMS
  class SubmissionResult < Hash
    attr_reader :id,
                :status,
                :datetime

    def initialize(id:, status:, datetime:)
      self['id']       = id
      self['status']   = status
      self['datetime'] = datetime
    end
  end
end
