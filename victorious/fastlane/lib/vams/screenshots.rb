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
      screenshot_urls.each do |url_string|
        FileHelper.download_file(url_string: url_string, location: dir)
      end
    end
  end
end
