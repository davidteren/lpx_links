require 'spec_helper'
require_relative '../lpx_links'

RSpec.describe LpxLinks do
  describe '.run' do
    xit 'creates required directories and files' do
      LpxLinks.run

      expect(File).to exist(FileHelpers.links_dir)
      expect(File).to exist(FileHelpers.json_dir)
      expect(File).to exist(FileHelpers.all_download_links)
      expect(File).to exist(FileHelpers.mandatory_download_links)

      # Clean up created files and directories after the test
      FileUtils.rm_rf(FileHelpers.links_dir)
    end
  end


  describe '.open_lpx_download_links' do
    # Test for opening the download_links folder
  end

  describe '.create_dirs' do
    # Test for creating necessary directories
  end

  # Continue adding more tests for different methods as needed
end
