require 'uri'
require 'vams/http'
require 'vams/file_helper'

module VAMS
  class Screenshots < OpenStruct
    def save(location:)
      each_pair do |language, screenshot_urls|
        language_dir_path = create_language_dir_if_needed(location: location, language: language)
        save_screenshots_into_dir(dir: language_dir_path, screenshot_urls: screenshot_urls)
      end
    end

    private

    def create_language_dir_if_needed(location:, language:)
      language_dir_path = File.join(location.to_s, language.to_s)
      FileHelper.make_directory_if_needed(path: language_dir_path)
      language_dir_path
    end

    def save_screenshots_into_dir(dir:, screenshot_urls:)
      screenshot_urls.each do |url|
        uri      = URI.parse(url)
        filename = File.basename(uri.path)
        response = HTTP.send_request_to_uri(type: :get, uri: uri)

        file_path = File.join(dir, filename)
        FileHelper.save_text_into_file(text: response.body, path: file_path)
      end
    end
  end
end
