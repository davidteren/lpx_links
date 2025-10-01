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
end
