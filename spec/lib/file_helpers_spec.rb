# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FileHelpers do
  describe '.plist_file_path' do
    it 'returns the correct path for Logic Pro' do
      logic_path = '/Applications/Logic Pro X.app/Contents/Resources'
      allow(FileHelpers).to receive(:app_path).with('LOGIC').and_return(logic_path)
      allow(FileHelpers).to receive(:plist_file_name).with('LOGIC').and_return('logicpro1040.plist')

      expected_path = "#{logic_path}/logicpro1040.plist"
      expect(FileHelpers.plist_file_path('LOGIC')).to eq(expected_path)
    end

    it 'returns the correct path for Mainstage' do
      mainstage_path = '/Applications/MainStage 3.app/Contents/Resources'
      allow(FileHelpers).to receive(:app_path).with('MAINSTAGE').and_return(mainstage_path)
      allow(FileHelpers).to receive(:plist_file_name).with('MAINSTAGE').and_return('mainstage360.plist')

      expected_path = "#{mainstage_path}/mainstage360.plist"
      expect(FileHelpers.plist_file_path('MAINSTAGE')).to eq(expected_path)
    end
  end

  describe '.app_path' do
    context 'when Logic Pro X is installed' do
      before do
        allow(File).to receive(:exist?).with('/Applications/Logic Pro X.app/Contents/Resources').and_return(true)
      end

      it 'returns the correct path' do
        expect(FileHelpers.app_path('LOGIC')).to eq('/Applications/Logic Pro X.app/Contents/Resources')
      end
    end

    context 'when Logic Pro is installed' do
      before do
        allow(File).to receive(:exist?).with('/Applications/Logic Pro X.app/Contents/Resources').and_return(false)
        allow(File).to receive(:exist?).with('/Applications/Logic Pro.app/Contents/Resources').and_return(true)
      end

      it 'returns the correct path' do
        expect(FileHelpers.app_path('LOGIC')).to eq('/Applications/Logic Pro.app/Contents/Resources')
      end
    end

    context 'when neither Logic Pro version is installed' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'raises an error' do
        expect { FileHelpers.app_path('LOGIC') }.to raise_error('Logic Pro X not found')
      end
    end
  end

  describe '.links_dir' do
    it 'returns the correct directory path' do
      allow(Dir).to receive(:home).and_return('/Users/testuser')
      expect(FileHelpers.links_dir).to eq('/Users/testuser/Desktop/lpx_download_links')
    end
  end
end
