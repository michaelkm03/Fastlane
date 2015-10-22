require 'json'

module VAMS
  class Client
    APP_JSON_PATH = File.join(File.dirname(__FILE__), 'app_submission.json')

    def self.apps_to_build
      json_string = File.read(APP_JSON_PATH)
      JSON.parse(json_string)
    end
  end
end
