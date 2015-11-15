require 'json'
require 'digest/sha1'
require 'vams/app'
require 'vams/payloads'
require 'vams/environment'
require 'httparty'

module VAMS
  class Client
    attr_reader :environment, :date

    DEFAULT_USER_ID = 0
    module Endpoints
      LOGIN     = '/api/login'
      APPS_LIST = '/api/app/apps_list'
    end

    def initialize(environment: :staging, date: construct_date)
      @environment = environment
      @date        = date
      @env         = Environment.send(environment.to_sym)
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

      response = send_request(type:    :post,
                              path:    Endpoints::LOGIN,
                              host:    @env.host,
                              headers: headers,
                              options: post_data)

      json    = JSON.parse(response.body)
      payload = json['payload']
      token   = payload['token']
      user_id = json['user_id'] || DEFAULT_USER_ID

      [token, user_id]
    end

    def apps_to_build
      endpoint = Endpoints::APPS_LIST
      headers = {
        'Authorization' => construct_auth_header(endpoint: endpoint),
        'User-Agent'    => @env.useragent,
        'Date'          => @date.to_s
      }

      response          = send_request(type:    :get,
                                       path:    endpoint,
                                       host:    @env.host,
                                       headers: headers)
      json              = JSON.parse(response.body)
      unlocked_app_data = json['payload'].select { |data| data['app_state'] == 'unlocked' }
      unlocked_app_data.map { |data| App.new(data) }
    end

    def app_by_build_name(build_name)
      json = json_from_file(path: APP_BY_BUILD_NAME)
      App.new(json['payload'])
    end

    def submit_result(result:, environment:)
      options = { body: result.to_json }
      send_request(type: :post, host: @env.host, path: '/submission_result', options: options)
    end

    private

    def send_request(type:, protocol: 'https://', host:, path:, options:{}, headers: {})
      HTTParty.send(type.to_sym, protocol + host + path, headers: headers, query: options)
    end

    def json_from_file(path:)
      json_string = File.read(path)
      JSON.parse(json_string)
    end

    def construct_date
      `date`.split(" ").join(" ")
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
