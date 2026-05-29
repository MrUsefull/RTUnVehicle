require 'minitest/autorun'
require 'tmpdir'
require 'json'
require_relative '../LanceFileProcessor'

class LanceFileProcessorTest < Minitest::Test
  def setup
    @tmpdir    = Dir.mktmpdir
    @src_dir   = File.join(@tmpdir, "Lances", "subfolder")
    @dest_dir  = File.join(@tmpdir, "NewLances")
    @log_file  = File.join(@tmpdir, "test.log")
    FileUtils.mkdir_p(@src_dir)

    @src_file  = File.join(@src_dir, "test_lance.json")
    @old_root  = File.join(@tmpdir, "Lances") + "/"
    @new_root  = File.join(@tmpdir, "NewLances") + "/"
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_untouched_copies_file_content_verbatim
    File.write(@src_file, "original content")
    LanceFileProcessor.saveFile(@old_root, @new_root, nil, @src_file, true, @log_file)
    expected_dest = @src_file.sub(@old_root, @new_root)
    assert_equal "original content", File.read(expected_dest)
  end

  def test_updated_writes_pretty_json
    File.write(@src_file, "{}")
    json_obj = { "unitType" => "Mech", "unitId" => "Tagged" }
    LanceFileProcessor.saveFile(@old_root, @new_root, json_obj, @src_file, false, @log_file)
    expected_dest = @src_file.sub(@old_root, @new_root)
    assert_equal JSON.pretty_generate(json_obj), File.read(expected_dest)
  end

  def test_creates_destination_directory_if_missing
    File.write(@src_file, "{}")
    refute File.exist?(@dest_dir)
    LanceFileProcessor.saveFile(@old_root, @new_root, {}, @src_file, true, @log_file)
    assert File.exist?(@dest_dir)
  end

  def test_creates_nested_destination_directory
    nested_src = File.join(@src_dir, "deep", "nested")
    FileUtils.mkdir_p(nested_src)
    nested_file = File.join(nested_src, "lance.json")
    File.write(nested_file, "{}")
    LanceFileProcessor.saveFile(@old_root, @new_root, {}, nested_file, true, @log_file)
    expected_dest = nested_file.sub(@old_root, @new_root)
    assert File.exist?(expected_dest)
  end

  def test_logs_message_on_untouched_write
    File.write(@src_file, "data")
    LanceFileProcessor.saveFile(@old_root, @new_root, nil, @src_file, true, @log_file)
    assert_includes File.read(@log_file), "Writing existing file untouched"
  end

  def test_logs_message_on_updated_write
    File.write(@src_file, "{}")
    LanceFileProcessor.saveFile(@old_root, @new_root, {}, @src_file, false, @log_file)
    assert_includes File.read(@log_file), "Copying Updated Lance File To"
  end
end
