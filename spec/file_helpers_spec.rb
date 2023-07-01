require "file_helpers"

describe FileHelpers do
  ENV["HOME"] = "/Users/some_user"
  describe ".all_download_links" do
    it "returns the path to all download links" do
      expect(described_class.all_download_links).to eq("/Users/some_user/Desktop/lpx_download_links/all_download_links.txt")
    end
  end

  describe ".mandatory_download_links" do
    it "returns the path to mandatory download links" do
      expect(described_class.mandatory_download_links).to eq("/Users/some_user/Desktop/lpx_download_links/mandatory_download_links.txt")
    end
  end

  describe ".json_file" do
    it "returns the path to the json file" do
      expect(described_class.json_file).to eq("/Users/some_user/Desktop/lpx_download_links/json/logicpro_content.json")
    end
  end

  describe ".links_dir" do
    it "returns the path to the links directory" do
      expect(described_class.links_dir).to eq("/Users/some_user/Desktop/lpx_download_links")
    end
  end

  describe ".json_dir" do
    it "returns the path to the json directory" do
      expect(described_class.json_dir).to eq("/Users/some_user/Desktop/lpx_download_links/json")
    end
  end

  describe ".plist_file_path" do
    it "returns the path to the plist file" do
      expect(described_class.plist_file_path("app_name")).to eq("expected/path/to/plist/file")
    end
  end

  describe ".url" do
    it "returns the base url" do
      expect(described_class.url).to eq("expected/base/url")
    end
  end
end
