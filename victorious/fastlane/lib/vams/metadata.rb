module VAMS
  class Metadata
    attr_reader :copyright,
                :ios_primary_category,
                :ios_secondary_category,
                :ios_description,
                :ios_keywords,
                :app_name,
                :privacy_policy_url,
                :support_url

    def initialize(app)
      @copyright              = app.copyright
      @ios_primary_category   = app.ios_primary_category
      @ios_secondary_category = app.ios_secondary_category
      @ios_description        = app.ios_description
      @ios_keywords           = app.ios_keywords
      @app_name               = app.app_name
      @privacy_policy_url     = app.privacy_policy_url
      @support_url            = app.support_url
    end

    def save(location:)
      file_path = File.join(location, 'copyright.txt')
      save_text_into_file(text: copyright, path: file_path)
    end

    private

    def save_text_into_file(text:, path:)
      File.open(path, File::WRONLY | File::CREAT) do |file|
        file.write(text)
      end
    end
  end
end
