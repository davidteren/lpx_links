 #!/usr/bin/env ruby

require 'json'
require 'fileutils'
require_relative 'file_helpers.rb'

# read the plist, create a json & parse a list of links
module LpxLinks
  include FileHelpers

  module_function

  def run
    create_dirs
    convert_plist_to_json
    print_file(all_download_links, download_links)
    print_file(mandatory_download_links, download_links(true))
    print_file(json_file, JSON.pretty_generate(packages))
    open_lpx_download_links
  end

  def open_lpx_download_links
    `open #{links_dir}`
  end

  def create_dirs
    FileUtils.mkdir_p(links_dir)
    FileUtils.mkdir_p(json_dir)
  end

  def convert_plist_to_json
    `plutil -convert json \'#{plist_file_path}\' -o /tmp/lgp_content.json`
  end

  def packages
    @packages ||= read_packages
  end

  def read_packages
    JSON.parse(File.read('/tmp/lgp_content.json'))['Packages']
  end

  def download_links(only_mandatory = false)
    links = []
    packages.each do |i|
      next if only_mandatory && !i[1]['IsMandatory']
      links << "#{File.join(url, i[1]['DownloadName'])}\n"
    end
    links.sort
  end

  def print_file(file, content)
    f = File.open(file, 'w')
    f.puts content
    f.close
  end
end

LpxLinks.run if $PROGRAM_NAME == __FILE__
