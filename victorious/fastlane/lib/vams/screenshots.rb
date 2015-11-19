require 'uri'
require 'vams/http'

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
      FileUtils.mkdir_p(language_dir_path) unless File.directory?(language_dir_path)
      language_dir_path
    end

    def save_screenshots_into_dir(dir:, screenshot_urls:)
      screenshot_urls.each do |url|
        uri      = URI.parse(url)
        filename = File.basename(uri.path)
        response = HTTP.send_request_to_uri(type: :get, uri: uri)

        File.open(File.join(dir, filename), File::WRONLY | File::CREAT) do |file|
          file.write(response.body)
        end
      end
    end
  end
end
