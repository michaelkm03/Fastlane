require 'vams/file_helper'

module VAMS
  class AppIcon
    attr_reader :logo_image

    def initialize(app:)
      @logo_image = app.original_logo_image
    end

    def save(location:, filename:)
      FileHelper.download_file(url_string: logo_image, location: location)
    end
  end
end
