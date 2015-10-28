require 'json'
require 'vams/app'
require 'vams/payloads'

module VAMS
  module Client
    extend self

    def apps_to_build
      json = json_from_file(path: APPS_TO_BUILD_JSON_PATH)
      json.map { |data| App.new(data) }
    end

    def app_by_build_name(build_name)
      json = json_from_file(path: APP_BY_BUILD_NAME)
      App.new(json)
    end

    private

    def json_from_file(path:)
      json_string = File.read(path)
      JSON.parse(json_string)
    end
  end
end
