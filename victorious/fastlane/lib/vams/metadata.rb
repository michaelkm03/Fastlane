module VAMS
  class Metadata
    CORE_ATTRIBUTES              = [:copyright,
                                    :primary_category,
                                    :secondary_category]
    LANGUAGE_SPECIFIC_ATTRIBUTES = [:description,
                                    :keywords,
                                    :privacy_url,
                                    :support_url,
                                    :name]
    attr_reader(*(CORE_ATTRIBUTES + LANGUAGE_SPECIFIC_ATTRIBUTES))

    def initialize(app)
      @ios_app_categories = app.ios_app_categories
      @copyright          = app.copyright
      @primary_category   = find_category_string(categories: app.ios_app_categories, number: app.ios_primary_category)
      @secondary_category = find_category_string(categories: app.ios_app_categories, number: app.ios_secondary_category)
      @description        = app.ios_description
      @keywords           = app.ios_keywords
      @privacy_url = app.privacy_policy_url
      @support_url        = app.support_url
      @name               = app.app_name
    end

    def save(location:, language:)
      CORE_ATTRIBUTES.each do |attribute|
        file_path = File.join(location, "#{attribute}.txt")
        save_text_into_file(text: self.send(attribute), path: file_path)
      end

      FileHelper.make_directory_if_needed(path: File.join(location, language))
      LANGUAGE_SPECIFIC_ATTRIBUTES.each do |attribute|
        file_path = File.join(location, language, "#{attribute}.txt")
        save_text_into_file(text: self.send(attribute), path: file_path)
      end
    end

    private

    def find_category_string(categories:, number:)
      category_pair = categories.detect { |string, number_in_hash|
        number_in_hash.to_i == number.to_i
      }
      category_pair.first if category_pair
    end

    def save_text_into_file(text:, path:)
      File.open(path, File::WRONLY | File::CREAT) do |file|
        file.write(text)
      end
    end
  end
end
