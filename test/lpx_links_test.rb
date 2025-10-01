# frozen_string_literal: true

require 'test_helper'

class LpxLinksTest < Minitest::Test
  def setup
    @sample_packages = {
      'Packages' => {
        'package1' => { 'DownloadName' => 'mandatory_package.pkg', 'IsMandatory' => true },
        'package2' => { 'DownloadName' => 'optional_package.pkg', 'IsMandatory' => false }
      }
    }
  end

  def teardown
    # Reset memoized packages after each test
    LpxLinks.instance_variable_set(:@packages, nil)
  end

  def test_download_links_returns_all_links_when_mandatory_flag_is_false
    File.stub(:read, @sample_packages.to_json) do
      FileHelpers.stub(:url, 'http://example.com/content/') do
        links = LpxLinks.download_links(only_mandatory: false)

        assert_equal 2, links.length
        assert_includes links, "http://example.com/content/mandatory_package.pkg\n"
        assert_includes links, "http://example.com/content/optional_package.pkg\n"
      end
    end
  end

  def test_download_links_returns_only_mandatory_links_when_mandatory_flag_is_true
    File.stub(:read, @sample_packages.to_json) do
      FileHelpers.stub(:url, 'http://example.com/content/') do
        links = LpxLinks.download_links(only_mandatory: true)

        assert_equal 1, links.length
        assert_includes links, "http://example.com/content/mandatory_package.pkg\n"
      end
    end
  end

  def test_read_packages_correctly_parses_json_file
    File.stub(:read, @sample_packages.to_json) do
      packages = LpxLinks.read_packages

      assert_equal @sample_packages['Packages'], packages
    end
  end

  def test_read_packages_raises_error_for_invalid_json
    File.stub(:read, 'invalid json') do
      assert_raises(JSON::ParserError) do
        LpxLinks.read_packages
      end
    end
  end

  def test_read_packages_raises_error_when_file_not_found
    File.stub(:read, ->(_path) { raise Errno::ENOENT, 'No such file' }) do
      assert_raises(Errno::ENOENT) do
        LpxLinks.read_packages
      end
    end
  end

  def test_download_links_handles_relative_paths_in_urls
    packages_with_relative_paths = {
      'Packages' => {
        'package1' => { 'DownloadName' => '../../content/package.pkg', 'IsMandatory' => true }
      }
    }

    File.stub(:read, packages_with_relative_paths.to_json) do
      FileHelpers.stub(:url, 'http://example.com/base/path/') do
        links = LpxLinks.download_links

        assert_equal 1, links.length
        assert_includes links, "http://example.com/content/package.pkg\n"
      end
    end
  end

  def test_download_links_sorts_results
    unsorted_packages = {
      'Packages' => {
        'package3' => { 'DownloadName' => 'zebra.pkg', 'IsMandatory' => false },
        'package1' => { 'DownloadName' => 'alpha.pkg', 'IsMandatory' => false },
        'package2' => { 'DownloadName' => 'beta.pkg', 'IsMandatory' => false }
      }
    }

    File.stub(:read, unsorted_packages.to_json) do
      FileHelpers.stub(:url, 'http://example.com/') do
        links = LpxLinks.download_links

        assert_equal "http://example.com/alpha.pkg\n", links[0]
        assert_equal "http://example.com/beta.pkg\n", links[1]
        assert_equal "http://example.com/zebra.pkg\n", links[2]
      end
    end
  end

  def test_print_file_writes_content_to_file
    require 'tempfile'

    Tempfile.create('test_output') do |tempfile|
      content = %w[line1 line2 line3]

      LpxLinks.print_file(tempfile.path, content)

      written_content = File.read(tempfile.path)
      assert_includes written_content, 'line1'
      assert_includes written_content, 'line2'
      assert_includes written_content, 'line3'
    end
  end

  def test_packages_method_caches_result
    call_count = 0
    File.stub(:read, lambda { |_path|
      call_count += 1
      @sample_packages.to_json
    }) do
      # Call packages twice
      LpxLinks.packages
      LpxLinks.packages

      # Should only read file once due to memoization
      assert_equal 1, call_count
    end
  end

  def test_create_dirs_creates_links_and_json_directories
    require 'tmpdir'

    Dir.mktmpdir do |tmpdir|
      links_dir = File.join(tmpdir, 'links')
      json_dir = File.join(tmpdir, 'json')

      FileHelpers.stub(:links_dir, links_dir) do
        FileHelpers.stub(:json_dir, json_dir) do
          LpxLinks.create_dirs

          assert Dir.exist?(links_dir), 'Links directory should exist'
          assert Dir.exist?(json_dir), 'JSON directory should exist'
        end
      end
    end
  end

  def test_convert_plist_to_json_executes_plutil_command
    executed_command = nil

    LpxLinks.stub(:`, lambda { |cmd|
      executed_command = cmd
      ''
    }) do
      FileHelpers.stub(:plist_file_path, '/path/to/file.plist') do
        LpxLinks.convert_plist_to_json

        assert_includes executed_command, 'plutil'
        assert_includes executed_command, '/path/to/file.plist'
        assert_includes executed_command, '/tmp/lgp_content.json'
      end
    end
  end

  def test_open_lpx_download_links_executes_open_command
    executed_command = nil

    LpxLinks.stub(:`, lambda { |cmd|
      executed_command = cmd
      ''
    }) do
      Dir.stub(:home, '/Users/testuser') do
        LpxLinks.open_lpx_download_links

        assert_includes executed_command, 'open'
        assert_includes executed_command, '/Users/testuser/Desktop/lpx_download_links'
      end
    end
  end

  def test_run_method_executes_full_workflow
    require 'tmpdir'

    Dir.mktmpdir do |tmpdir|
      links_dir = File.join(tmpdir, 'links')
      json_dir = File.join(tmpdir, 'json')

      # Stub all the necessary methods
      FileHelpers.stub(:links_dir, links_dir) do
        FileHelpers.stub(:json_dir, json_dir) do
          FileHelpers.stub(:all_download_links, File.join(links_dir, 'all.txt')) do
            FileHelpers.stub(:mandatory_download_links, File.join(links_dir, 'mandatory.txt')) do
              FileHelpers.stub(:json_file, File.join(json_dir, 'content.json')) do
                FileHelpers.stub(:plist_file_path, '/path/to/plist') do
                  LpxLinks.stub(:`, '') do
                    File.stub(:read, @sample_packages.to_json) do
                      FileHelpers.stub(:url, 'http://example.com/') do
                        # Run the method
                        LpxLinks.run

                        # Verify directories were created
                        assert Dir.exist?(links_dir), 'Links directory should exist'
                        assert Dir.exist?(json_dir), 'JSON directory should exist'

                        # Verify files were created
                        assert File.exist?(File.join(links_dir, 'all.txt')), 'All links file should exist'
                        assert File.exist?(File.join(links_dir, 'mandatory.txt')),
                               'Mandatory links file should exist'
                        assert File.exist?(File.join(json_dir, 'content.json')), 'JSON file should exist'
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def test_run_method_handles_runtime_errors
    # Stub to raise a RuntimeError
    LpxLinks.stub(:create_dirs, -> { raise 'Test error' }) do
      # Capture the exit call
      exit_called = false
      exit_code = nil

      LpxLinks.stub(:exit, lambda { |code|
        exit_called = true
        exit_code = code
      }) do
        # Capture stdout
        output = capture_io do
          LpxLinks.run
        end

        assert exit_called, 'Exit should be called'
        assert_equal 1, exit_code, 'Exit code should be 1'
        assert_includes output[0], 'Error: Test error'
      end
    end
  end
end
