module FileTestHelper
  TEST_DIR_PATH = File.join(__dir__, '..')
  TMP_DIR       = File.join(TEST_DIR_PATH, 'tmp')

  def read_file(*paths)
    File.read(File.join(paths))
  end

  def assert_file_exists(*paths)
    file_location = File.join(paths)
    assert(File.exists?(file_location))
  end

  def clean_tmp_dir
    FileUtils.rm_rf(Dir["#{TMP_DIR.to_s}/*"])
  end
end
