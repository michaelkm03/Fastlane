# coding: utf-8
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
      response          = HTTP.send_request(type:     :get,
                                            path:     endpoint,
                                            host:     @env.host,
                                            protocol: @env.protocol,
                                            headers:  construct_headers(endpoint: endpoint))
      json              = JSON.parse(response.body)

      # HACK: Temporarily submit only the leachypeachy app.
      #       Even if app is pretty awesome 😃, we'll need to submit apps
      #       with the unlocked app state when it becomes available in
      #       production VAMS api.
      #
      # unlocked_app_data = json['payload'].select { |data| data['build_name'] == 'leachypeachy99' }
      unlocked_app_data = json['payload'].select { |data| data['app_state'] == 'unlocked' }
      unlocked_app_data.map { |data| App.new(data) }
    end

    def app_by_build_name(build_name)
      endpoint = Endpoints::APP_BY_BUILD_NAME + '/' + build_name
      response = HTTP.send_request(type:     :get,
                                   path:     endpoint,
                                   host:     @env.host,
                                   protocol: @env.protocol,
                                   headers:  construct_headers(endpoint: endpoint))
      json     = JSON.parse(response.body)
      App.new(json['payload'])
    end

    def get_screenshots(build_name)
      endpoint = Endpoints::SCREENSHOTS + '/' + build_name
      response = HTTP.send_request(type:     :get,
                                   path:     endpoint,
                                   host:     @env.host,
                                   protocol: @env.protocol,
                                   headers:  construct_headers(endpoint: endpoint))
      json     = JSON.parse(response.body)
      Screenshots.new(json['payload'])
    end

    def submit_result(result)
      endpoint = Endpoints::SUBMISSION_RESPONSE
      HTTP.send_request(type:     :post,
                        host:     @env.host,
                        protocol: @env.protocol,
                        path:     endpoint,
                        body:     result,
                        headers:  construct_headers(endpoint: endpoint))
    end

    private

    def construct_headers(endpoint:)
      {
        'Authorization' => construct_auth_header(endpoint: endpoint),
        'User-Agent'    => @env.useragent,
        'Date'          => @date.to_s
      }
    end

    def auth_data
      (@token && @user_id) ? [@token, @user_id] : authenticate
    end

    def construct_auth_header(endpoint:)
      token, user_id = auth_data
      hash_data      = "#{@date}#{endpoint}#{@env.useragent}#{token}GET"
      auth_hash      = Digest::SHA1.hexdigest(hash_data)
      "BASIC #{user_id}:#{auth_hash}"
    end
  end
end
