module VAMS
  class Screenshots < OpenStruct
    def save(location:)
      each_pair do |language, screenshots|
        language_dir_path = File.join(location.to_s, language.to_s)
        FileUtils.mkdir_p(language_dir_path) unless File.directory?(language_dir_path)
      end
    end
  end
end
