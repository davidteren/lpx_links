# Mostly path setters
module FileHelpers
  module_function

  def plist_file_path
    File.join(logic_app_path, plist_file_name)
  end

  def logic_app_path
    path = '/Applications/Logic Pro X.app/Contents/Resources'
    return path if File.exist?(path)

    path = '/Applications/Logic Pro.app/Contents/Resources'
    return path if File.exist?(path)

    raise 'Logic Pro X not found'
  end

  # Returns current filename: i.e. 'logicpro1040.plist'
  def plist_file_name
    `cd '#{logic_app_path}' && find . -name  logicpro\*.plist`
      .gsub('./', '').chomp
  end

  def temp_dir
    File.join(File.dirname(__FILE__), '/tmp')
  end

  def tmp_json
    @tmp_json ||= File.expand_path('tmp', 'lgp_content.json')
  end

  def links_dir
    @links_dir ||= File.join(ENV['HOME'], 'Desktop/lpx_download_links')
  end

  def all_download_links
    File.join(links_dir, 'all_download_links.txt')
  end

  def mandatory_download_links
    File.join(links_dir, 'mandatory_download_links.txt')
  end

  def json_file
    File.join(json_dir, 'logicpro_content.json')
  end

  def json_dir
    File.join(links_dir, 'json')
  end

  def url
    @url ||= 'http://audiocontentdownload.apple.com/lp10_ms3_content_2016/'
  end
end
