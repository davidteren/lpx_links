# frozen_string_literal: true

require 'test_helper'

class FileHelpersTest < Minitest::Test
  def test_plist_file_path_returns_correct_path_for_logic_pro
    logic_path = '/Applications/Logic Pro X.app/Contents/Resources'
    FileHelpers.stub(:app_path, logic_path) do
      FileHelpers.stub(:plist_file_name, 'logicpro1040.plist') do
        expected_path = "#{logic_path}/logicpro1040.plist"

        assert_equal expected_path, FileHelpers.plist_file_path('LOGIC')
      end
    end
  end

  def test_plist_file_path_returns_correct_path_for_mainstage
    mainstage_path = '/Applications/MainStage 3.app/Contents/Resources'
    FileHelpers.stub(:app_path, mainstage_path) do
      FileHelpers.stub(:plist_file_name, 'mainstage360.plist') do
        expected_path = "#{mainstage_path}/mainstage360.plist"

        assert_equal expected_path, FileHelpers.plist_file_path('MAINSTAGE')
      end
    end
  end

  def test_app_path_returns_correct_path_when_logic_pro_x_is_installed
    File.stub(:exist?, true) do
      result = FileHelpers.app_path('LOGIC')

      assert_equal '/Applications/Logic Pro X.app/Contents/Resources', result
    end
  end

  def test_app_path_returns_correct_path_when_logic_pro_is_installed
    # Create a custom stub that returns different values based on the path
    File.stub(:exist?, lambda { |path|
      path == '/Applications/Logic Pro.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('LOGIC')
      assert_equal '/Applications/Logic Pro.app/Contents/Resources', result
    end
  end

  def test_app_path_raises_error_when_neither_logic_pro_version_is_installed
    File.stub(:exist?, false) do
      error = assert_raises(RuntimeError) do
        FileHelpers.app_path('LOGIC')
      end

      assert_equal 'Logic Pro X not found', error.message
    end
  end

  def test_links_dir_returns_correct_directory_path
    Dir.stub(:home, '/Users/testuser') do
      expected_path = '/Users/testuser/Desktop/lpx_download_links'

      assert_equal expected_path, FileHelpers.links_dir
    end
  end

  def test_app_path_raises_error_for_mainstage_when_not_installed
    File.stub(:exist?, false) do
      error = assert_raises(RuntimeError) do
        FileHelpers.app_path('MAINSTAGE')
      end

      assert_equal 'Mainstage not found', error.message
    end
  end

  def test_app_path_raises_error_for_invalid_app_name
    error = assert_raises(RuntimeError) do
      FileHelpers.app_path('INVALID')
    end

    assert_equal 'No application paths found', error.message
  end

  def test_find_mainstage_path_returns_correct_path
    File.stub(:exist?, true) do
      result = FileHelpers.find_mainstage_path

      assert_equal '/Applications/MainStage 3.app/Contents/Resources', result
    end
  end

  def test_all_download_links_returns_correct_path
    Dir.stub(:home, '/Users/testuser') do
      expected_path = '/Users/testuser/Desktop/lpx_download_links/all_download_links.txt'

      assert_equal expected_path, FileHelpers.all_download_links
    end
  end

  def test_mandatory_download_links_returns_correct_path
    Dir.stub(:home, '/Users/testuser') do
      expected_path = '/Users/testuser/Desktop/lpx_download_links/mandatory_download_links.txt'

      assert_equal expected_path, FileHelpers.mandatory_download_links
    end
  end

  def test_json_file_returns_correct_path
    Dir.stub(:home, '/Users/testuser') do
      expected_path = '/Users/testuser/Desktop/lpx_download_links/json/logicpro_content.json'

      assert_equal expected_path, FileHelpers.json_file
    end
  end

  def test_json_dir_returns_correct_path
    Dir.stub(:home, '/Users/testuser') do
      expected_path = '/Users/testuser/Desktop/lpx_download_links/json'

      assert_equal expected_path, FileHelpers.json_dir
    end
  end

  def test_url_returns_correct_url
    expected_url = 'http://audiocontentdownload.apple.com/lp10_ms3_content_2016/'

    assert_equal expected_url, FileHelpers.url
  end

  def test_plist_file_name_returns_correct_filename
    # Stub the backtick command execution
    FileHelpers.stub(:`, 'logicpro1040.plist') do
      FileHelpers.stub(:app_path, '/Applications/Logic Pro.app/Contents/Resources') do
        result = FileHelpers.plist_file_name('LOGIC')

        assert_equal 'logicpro1040.plist', result
      end
    end
  end

  def test_plist_file_name_strips_dot_slash_prefix
    # Stub the backtick command execution with ./ prefix
    FileHelpers.stub(:`, './logicpro1040.plist') do
      FileHelpers.stub(:app_path, '/Applications/Logic Pro.app/Contents/Resources') do
        result = FileHelpers.plist_file_name('LOGIC')

        assert_equal 'logicpro1040.plist', result
      end
    end
  end

  def test_temp_dir_returns_correct_path
    result = FileHelpers.temp_dir

    assert_includes result, '/lib/tmp'
    assert result.end_with?('/lib/tmp')
  end
end
