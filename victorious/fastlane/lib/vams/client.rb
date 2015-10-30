require 'json'
require 'vams/app'
require 'vams/payloads'
require 'httparty'

module VAMS
  module Client
    extend self

    API_HOST              = 'api.getvictorious.com'
    LOGIN_ENDPOINT        = '/api/login'
    DEFAULT_VAMS_USERID   = 0
    DEFAULT_VAMS_USER     = ENV['VAMS_USER']
    DEFAULT_VAMS_PASSWORD = ENV['VAMS_PASSWORD']
    DEFAULT_USERAGENT     = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36 aid:11 uuid:FFFFFFFF-0000-0000-0000-FFFFFFFFFFFF build:1'

    def authenticate(date: Time.now)
      date      = date.to_s
      post_data = {
        email: DEFAULT_VAMS_USER,
        password: DEFAULT_VAMS_PASSWORD
      }
      headers = {
        'User-Agent' => DEFAULT_USERAGENT,
        'Date' => date
      }

      response = send_request(type: :get,
                              path: LOGIN_ENDPOINT,
                              headers: headers,
                              options: post_data)
      JSON.parse(response.body)['payload']['token']
    end

    def apps_to_build
      json = json_from_file(path: APPS_TO_BUILD_JSON_PATH)
      json.map { |data| App.new(data) }
    end

    def app_by_build_name(build_name)
      json = json_from_file(path: APP_BY_BUILD_NAME)
      App.new(json['payload'])
    end

    def submit_result(result)
      options = { body: result.to_json }
      send_request(type: :post, path: '/submission_result', options: options)
    end

    private

    def send_request(type:, protocol: 'https://', host: API_HOST, path:, options:{}, headers: {})
      HTTParty.send(type.to_sym, protocol + host + path, headers: headers, query: options)
    end

    def json_from_file(path:)
      json_string = File.read(path)
      JSON.parse(json_string)
    end
  end
end
