require 'json'
require 'digest/sha1'
require 'vams/app'
require 'vams/environment'
require 'vams/screenshots'
require 'vams/http'

module VAMS
  class Client
    attr_reader :environment, :date

    DEFAULT_USER_ID = 0
    module Endpoints
      LOGIN               = '/api/login'
      APPS_LIST           = '/api/app/apps_list'
      APP_BY_BUILD_NAME   = '/api/app/app_by_build_name'
      SUBMISSION_RESPONSE = '/api/app/app_submission_response'
      SCREENSHOTS         = '/api/app/screenshots'
    end

    def initialize(environment: :staging, date: Time.now)
      @environment = environment
      @date        = date
      @env         = Environment.construct(environment.to_sym)
    end

    def authenticate
      post_data = {
        email:    @env.username,
        password: @env.password
      }
      headers   = {
        'User-Agent' => @env.useragent,
        'Date'       => @date.to_s
      }

      response = HTTP.send_request(type:     :post,
                                   path:     Endpoints::LOGIN,
                                   protocol: @env.protocol,
                                   host:     @env.host,
                                   headers:  headers,
                                   options:  post_data)

      json    = JSON.parse(response.body)
      payload = json['payload']
      token   = payload['token']
      user_id = json['user_id'] || DEFAULT_USER_ID

      [token, user_id]
    end

    def apps_to_build
      endpoint          = Endpoints::APPS_LIST
      method            = :get
      response          = HTTP.send_request(type:     method,
                                            path:     endpoint,
                                            host:     @env.host,
                                            protocol: @env.protocol,
                                            headers:  construct_headers(endpoint: endpoint, method: method))
      json              = JSON.parse(response.body)

      unlocked_app_data = json['payload'].select { |data| data['ios_release_state'] == App::STATE::ON_DECK }
      unlocked_app_data.map { |data| App.new(data) }
    end

    def app_by_build_name(build_name)
      endpoint = Endpoints::APP_BY_BUILD_NAME + '/' + build_name
      method   = :get
      response = HTTP.send_request(type:     method,
                                   path:     endpoint,
                                   host:     @env.host,
                                   protocol: @env.protocol,
                                   headers:  construct_headers(endpoint: endpoint, method: method))
      json     = JSON.parse(response.body)
      App.new(json['payload'])
    end

    def get_screenshots(build_name)
      endpoint = Endpoints::SCREENSHOTS + '/' + build_name
      method   = :get
      response = HTTP.send_request(type:     method,
                                   path:     endpoint,
                                   host:     @env.host,
                                   protocol: @env.protocol,
                                   headers:  construct_headers(endpoint: endpoint, method: method))
      json     = JSON.parse(response.body)
      Screenshots.new(json['payload'])
    end

    def submit_result(result)
      endpoint = Endpoints::SUBMISSION_RESPONSE
      method   = :post
      response = HTTP.send_request(type:     method,
                                   host:     @env.host,
                                   protocol: @env.protocol,
                                   path:     endpoint,
                                   body:     result,
                                   headers:  construct_headers(endpoint: endpoint, method: method))
      if !successful_response?(status_code: response.code)
        error_message = "Failed to save a status for #{result}. Here is the response from VAMS: #{response}}"
        raise SubmissionResult::FailedResponseError.new(error_message)
      end

      response
    end

    private

    def construct_headers(endpoint:, method:)
      {
        'Authorization' => construct_auth_header(endpoint: endpoint, method: method),
        'User-Agent'    => @env.useragent,
        'Date'          => @date.to_s
      }
    end

    def auth_data
      (@token && @user_id) ? [@token, @user_id] : authenticate
    end

    def construct_auth_header(endpoint:, method:)
      token, user_id = auth_data
      hash_data      = "#{@date}#{endpoint}#{@env.useragent}#{token}#{method.to_s.upcase}"
      auth_hash      = Digest::SHA1.hexdigest(hash_data)
      "BASIC #{user_id}:#{auth_hash}"
    end

    def successful_response?(status_code:, non_error_codes: [200, 201])
      non_error_codes.include?(status_code)
    end
  end
end
