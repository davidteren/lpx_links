# frozen_string_literal: true

# Mostly path setters
module FileHelpers
  module_function

  def plist_file_path(app_name)
    File.join(app_path(app_name), plist_file_name(app_name))
  end

  def app_path(app_name)
    case app_name
    when 'LOGIC'
      find_logic_path
    when 'MAINSTAGE'
      find_mainstage_path
    else
      raise 'No application paths found'
    end
  end

  def find_logic_path
    path = '/Applications/Logic Pro X.app/Contents/Resources'
    return path if File.exist?(path)

    path = '/Applications/Logic Pro.app/Contents/Resources'
    return path if File.exist?(path)

    raise 'Logic Pro X not found'
  end

  def find_mainstage_path
    path = '/Applications/MainStage 3.app/Contents/Resources'
    return path if File.exist?(path)

    raise 'Mainstage not found'
  end

  # Returns current filename: i.e. 'logicpro1040.plist' or 'mainstage360.plist'
  def plist_file_name(app_name)
    `cd '#{app_path(app_name)}' && find . -name  logicpro\*.plist -o -name mainstage\*.plist`
      .gsub('./', '').chomp
  end

  def temp_dir
    File.join(File.dirname(__FILE__), '/tmp')
  end

  def tmp_json
    @tmp_json ||= File.expand_path('tmp', 'lgp_content.json')
  end

  def links_dir
    @links_dir ||= File.join(Dir.home, 'Desktop/lpx_download_links')
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
