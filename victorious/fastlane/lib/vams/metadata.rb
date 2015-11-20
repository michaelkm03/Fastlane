module VAMS
  class Metadata
    ATTRIBUTES = [:copyright,
                       :primary_category,
                       :secondary_category,
                       :description,
                       :keywords,
                       :privacy_url,
                       :support_url,
                       :name]

    attr_reader(*ATTRIBUTES)

    def initialize(app)
      @copyright          = app.copyright
      @primary_category   = app.ios_primary_category
      @secondary_category = app.ios_secondary_category
      @description        = app.ios_description
      @keywords           = app.ios_keywords
      @privacy_policy_url = app.privacy_policy_url
      @support_url        = app.support_url
      @name               = app.app_name
    end

    def save(location:)
      ATTRIBUTES.each do |attribute|
        file_path = File.join(location, "#{attribute}.txt")
        save_text_into_file(text: self.send(attribute), path: file_path)
      end
    end

    private

    def save_text_into_file(text:, path:)
      File.open(path, File::WRONLY | File::CREAT) do |file|
        file.write(text)
      end
    end
  end
end
