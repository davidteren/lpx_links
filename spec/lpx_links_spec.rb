require './lpx_links'

describe LpxLinks do
  describe '.run' do
    it 'calls the necessary methods' do
      expect(subject).to receive(:create_dirs)
      expect(subject).to receive(:convert_plist_to_json)
      expect(subject).to receive(:print_file).exactly(3).times
      expect(subject).to receive(:open_lpx_download_links)

      subject.run
    end
  end

  describe '.open_lpx_download_links' do
    it 'opens the links directory' do
      expect(subject).to receive(:`).with("open #{FileHelpers.links_dir}")

      subject.open_lpx_download_links
    end
  end

  describe '.create_dirs' do
    it 'creates necessary directories' do
      expect(FileUtils).to receive(:mkdir_p).with(FileHelpers.links_dir)
      expect(FileUtils).to receive(:mkdir_p).with(FileHelpers.json_dir)

      subject.create_dirs
    end
  end

  describe '.convert_plist_to_json' do
    it 'converts plist to json' do
      expect(subject).to receive(:`).with("plutil -convert json \'#{FileHelpers.plist_file_path($app_name)}\' -o /tmp/lgp_content.json")

      subject.convert_plist_to_json
    end
  end

  describe '.packages' do
    it 'reads packages from json file' do
      expect(subject).to receive(:read_packages)

      subject.packages
    end
  end

  describe '.read_packages' do
    it 'reads packages from json file' do
      json_content = { "Packages" => [] }.to_json
      allow(File).to receive(:read).with("/tmp/lgp_content.json").and_return(json_content)

      expect(subject.read_packages).to eq([])
    end
  end

  describe '.download_links' do
    it 'returns sorted download links' do
      packages = [
        ["package1", { "IsMandatory" => true, "DownloadName" => "download1" }],
        ["package2", { "IsMandatory" => false, "DownloadName" => "download2" }]
      ]
      allow(subject).to receive(:packages).and_return(packages)

      expect(subject.download_links).to eq(["download1\n", "download2\n"].sort)
    end
  end

  describe '.print_file' do
    it 'writes content to file' do
      file = double('File')
      allow(File).to receive(:open).with('file', 'w').and_yield(file)
      expect(file).to receive(:puts).with('content')

      subject.print_file('file', 'content')
    end
  end
end