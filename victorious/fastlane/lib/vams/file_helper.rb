module VAMS
  module FileHelper
    extend self

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
