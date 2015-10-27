require 'active_support/json'
require 'httparty'

module VAMS
  class SubmissionResult < Hash
    include HTTParty
    base_uri 'example.com'
    PATH = '/submission_result'

    attr_reader :id,
                :status,
                :datetime

    def initialize(id:, status:, datetime:)
      self['id']       = id
      self['status']   = status
      self['datetime'] = datetime
    end

    def submit
      options = { body: self.to_json }
      self.class.post(PATH, options)
    end
  end
end
