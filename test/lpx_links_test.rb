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
end
