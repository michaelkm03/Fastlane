require 'json'
require 'vams/app'
require 'vams/payloads'
require 'vams/environment'
require 'httparty'

module VAMS
  module Client
    extend self

    module Endpoints
      LOGIN = '/api/login'
    end

    DEFAULT_USER_ID = 0

    def authenticate(date: `date`.split(" ").join(" "), environment: :staging)
      env = Environment.send(environment)
      date      = date.to_s
      post_data = {
        email: env.username,
        password: env.password
      }
      headers = {
        'User-Agent' => env.useragent,
        'Date' => date
      }

      response = send_request(type:    :post,
                              path:    Endpoints::LOGIN,
                              host:    env.host,
                              headers: headers,
                              options: post_data)

      json    = JSON.parse(response.body)
      payload = json['payload']
      token   = payload['token']
      user_id = json['user_id'] || DEFAULT_USER_ID

      [token, user_id]
    end

    def apps_to_build
      json = json_from_file(path: APPS_TO_BUILD_JSON_PATH)
      json.map { |data| App.new(data) }
    end

    def app_by_build_name(build_name)
      json = json_from_file(path: APP_BY_BUILD_NAME)
      App.new(json['payload'])
    end

    def submit_result(result:, environment:)
      options = { body: result.to_json }
      env     = Environment.send(environment.to_sym)
      send_request(type: :post, host: env.host, path: '/submission_result', options: options)
    end

    private

    def send_request(type:, protocol: 'https://', host:, path:, options:{}, headers: {})
      HTTParty.send(type.to_sym, protocol + host + path, headers: headers, query: options)
    end

    def json_from_file(path:)
      json_string = File.read(path)
      JSON.parse(json_string)
    end
  end
end
