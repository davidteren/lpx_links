# frozen_string_literal: true

require 'test_helper'

class FileHelpersTest < Minitest::Test
  def test_plist_file_path_returns_correct_path_for_logic_pro
    logic_path = '/Applications/Logic Pro.app/Contents/Resources'
    FileHelpers.stub(:app_path, logic_path) do
      FileHelpers.stub(:plist_file_name, 'logicpro1120.plist') do
        expected_path = "#{logic_path}/logicpro1120.plist"

        assert_equal expected_path, FileHelpers.plist_file_path('LOGIC')
      end
    end
  end

  def test_plist_file_path_returns_correct_path_for_mainstage
    mainstage_path = '/Applications/MainStage 3.app/Contents/Resources'
    FileHelpers.stub(:app_path, mainstage_path) do
      FileHelpers.stub(:plist_file_name, 'mainstage370.plist') do
        expected_path = "#{mainstage_path}/mainstage370.plist"

        assert_equal expected_path, FileHelpers.plist_file_path('MAINSTAGE')
      end
    end
  end

  def test_plist_file_path_returns_correct_path_for_garageband
    gb_path = '/Applications/GarageBand.app/Contents/Resources'
    FileHelpers.stub(:app_path, gb_path) do
      FileHelpers.stub(:plist_file_name, 'garageband10412.plist') do
        expected_path = "#{gb_path}/garageband10412.plist"

        assert_equal expected_path, FileHelpers.plist_file_path('GARAGEBAND')
      end
    end
  end

  # Logic Pro path detection — tries Creator Studio, then Logic Pro, then Logic Pro X
  def test_app_path_finds_logic_pro_creator_studio
    File.stub(:exist?, lambda { |path|
      path == '/Applications/Logic Pro Creator Studio.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('LOGIC')
      assert_equal '/Applications/Logic Pro Creator Studio.app/Contents/Resources', result
    end
  end

  def test_app_path_finds_logic_pro
    File.stub(:exist?, lambda { |path|
      path == '/Applications/Logic Pro.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('LOGIC')
      assert_equal '/Applications/Logic Pro.app/Contents/Resources', result
    end
  end

  def test_app_path_finds_logic_pro_x
    File.stub(:exist?, lambda { |path|
      path == '/Applications/Logic Pro X.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('LOGIC')
      assert_equal '/Applications/Logic Pro X.app/Contents/Resources', result
    end
  end

  def test_app_path_raises_error_when_no_logic_pro_found
    File.stub(:exist?, false) do
      error = assert_raises(RuntimeError) do
        FileHelpers.app_path('LOGIC')
      end

      assert_equal 'Logic Pro not found', error.message
    end
  end

  # MainStage path detection — tries Creator Studio, then MainStage 3, then MainStage
  def test_app_path_finds_mainstage_creator_studio
    File.stub(:exist?, lambda { |path|
      path == '/Applications/MainStage Creator Studio.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('MAINSTAGE')
      assert_equal '/Applications/MainStage Creator Studio.app/Contents/Resources', result
    end
  end

  def test_app_path_finds_mainstage_three
    File.stub(:exist?, lambda { |path|
      path == '/Applications/MainStage 3.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('MAINSTAGE')
      assert_equal '/Applications/MainStage 3.app/Contents/Resources', result
    end
  end

  def test_app_path_raises_error_when_no_mainstage_found
    File.stub(:exist?, false) do
      error = assert_raises(RuntimeError) do
        FileHelpers.app_path('MAINSTAGE')
      end

      assert_equal 'MainStage not found', error.message
    end
  end

  # GarageBand path detection
  def test_app_path_finds_garageband
    File.stub(:exist?, lambda { |path|
      path == '/Applications/GarageBand.app/Contents/Resources'
    }) do
      result = FileHelpers.app_path('GARAGEBAND')
      assert_equal '/Applications/GarageBand.app/Contents/Resources', result
    end
  end

  def test_app_path_raises_error_when_no_garageband_found
    File.stub(:exist?, false) do
      error = assert_raises(RuntimeError) do
        FileHelpers.app_path('GARAGEBAND')
      end

      assert_equal 'GarageBand not found', error.message
    end
  end

  def test_app_path_raises_error_for_invalid_app_name
    error = assert_raises(RuntimeError) do
      FileHelpers.app_path('INVALID')
    end

    assert_equal 'No application paths found', error.message
  end

  def test_links_dir_returns_correct_directory_path
    Dir.stub(:home, '/Users/testuser') do
      expected_path = '/Users/testuser/Desktop/lpx_download_links'

      assert_equal expected_path, FileHelpers.links_dir
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
    FileHelpers.stub(:`, 'logicpro1120.plist') do
      FileHelpers.stub(:app_path, '/Applications/Logic Pro.app/Contents/Resources') do
        result = FileHelpers.plist_file_name('LOGIC')

        assert_equal 'logicpro1120.plist', result
      end
    end
  end

  def test_plist_file_name_strips_dot_slash_prefix
    FileHelpers.stub(:`, './logicpro1120.plist') do
      FileHelpers.stub(:app_path, '/Applications/Logic Pro.app/Contents/Resources') do
        result = FileHelpers.plist_file_name('LOGIC')

        assert_equal 'logicpro1120.plist', result
      end
    end
  end

  def test_plist_file_name_finds_garageband_plist
    FileHelpers.stub(:`, 'garageband10412.plist') do
      FileHelpers.stub(:app_path, '/Applications/GarageBand.app/Contents/Resources') do
        result = FileHelpers.plist_file_name('GARAGEBAND')

        assert_equal 'garageband10412.plist', result
      end
    end
  end

  def test_temp_dir_returns_correct_path
    result = FileHelpers.temp_dir

    assert_includes result, '/lib/tmp'
    assert result.end_with?('/lib/tmp')
  end
end
