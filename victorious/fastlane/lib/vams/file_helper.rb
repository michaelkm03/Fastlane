require 'uri'
require 'vams/http'

module VAMS
  module FileHelper
    extend self

    def download_file(url_string:, location:)
      uri      = URI.parse(url_string)
      filename = File.basename(uri.path)
      response = HTTP.send_request_to_uri(type: :get, uri: uri)

      file_path = File.join(location, filename)
      FileHelper.save_text_into_file(text: response.body, path: file_path)
    end

    def save_text_into_file(text:, path:)
      File.open(path, File::WRONLY | File::CREAT) do |file|
        file.write(text)
      end
    end

    def make_directory_if_needed(path:)
      FileUtils.mkdir_p(path) unless File.directory?(path)
    end
  end
end
