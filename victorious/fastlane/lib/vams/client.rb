require 'json'
require 'vams/app'
require 'vams/payloads'
require 'httparty'

module VAMS
  module Client
    extend self

    VAMS_API_HOST = 'example.com'

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

    def send_request(type:, protocol: 'https://', host: VAMS_API_HOST, path:, options:)
      HTTParty.send(type.to_sym, protocol + host + path, options)
    end

    def json_from_file(path:)
      json_string = File.read(path)
      JSON.parse(json_string)
    end
  end
end
