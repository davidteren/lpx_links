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
    when 'GARAGEBAND'
      find_garageband_path
    else
      raise 'No application paths found'
    end
  end

  def find_logic_path
    [
      '/Applications/Logic Pro Creator Studio.app/Contents/Resources',
      '/Applications/Logic Pro.app/Contents/Resources',
      '/Applications/Logic Pro X.app/Contents/Resources'
    ].each { |p| return p if File.exist?(p) }

    raise 'Logic Pro not found'
  end

  def find_mainstage_path
    [
      '/Applications/MainStage Creator Studio.app/Contents/Resources',
      '/Applications/MainStage 3.app/Contents/Resources',
      '/Applications/MainStage.app/Contents/Resources'
    ].each { |p| return p if File.exist?(p) }

    raise 'MainStage not found'
  end

  def find_garageband_path
    path = '/Applications/GarageBand.app/Contents/Resources'
    return path if File.exist?(path)

    raise 'GarageBand not found'
  end

  # Returns current filename: i.e. 'logicpro1040.plist' or 'mainstage360.plist' or 'garageband10412.plist'
  def plist_file_name(app_name)
    pattern = '-name logicpro\\*.plist -o -name mainstage\\*.plist -o -name garageband\\*.plist'
    `cd '#{app_path(app_name)}' && find . #{pattern}`
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
