# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LpxLinks do
  let(:sample_packages) do
    {
      'Packages' => {
        'package1' => {
          'DownloadName' => 'mandatory_package.pkg',
          'IsMandatory' => true
        },
        'package2' => {
          'DownloadName' => 'optional_package.pkg',
          'IsMandatory' => false
        }
      }
    }
  end

  before do
    allow(File).to receive(:read).with('/tmp/lgp_content.json').and_return(sample_packages.to_json)
    allow(FileHelpers).to receive(:url).and_return('http://example.com/content/')
  end

  describe '.download_links' do
    it 'returns all download links when mandatory flag is false' do
      links = LpxLinks.download_links(only_mandatory: false)
      expect(links.length).to eq(2)
      expect(links).to include("http://example.com/content/mandatory_package.pkg\n")
      expect(links).to include("http://example.com/content/optional_package.pkg\n")
    end

    it 'returns only mandatory download links when mandatory flag is true' do
      links = LpxLinks.download_links(only_mandatory: true)
      expect(links.length).to eq(1)
      expect(links).to include("http://example.com/content/mandatory_package.pkg\n")
    end
  end

  describe '.read_packages' do
    it 'correctly parses the JSON file' do
      packages = LpxLinks.read_packages
      expect(packages).to eq(sample_packages['Packages'])
    end
  end
end
