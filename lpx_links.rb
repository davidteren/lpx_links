#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'pathname'
require 'uri'
require 'optparse'
require_relative 'lib/file_helpers'

# read the plist, create a json & parse a list of links
module LpxLinks
  module_function

  @app_name = 'LOGIC' # default application name to read a list of packages from

  class << self
    attr_accessor :app_name
  end

  self.app_name = 'LOGIC'

  OptionParser.new do |opts|
    opts.on('-nAPP_NAME', '--name=APP_NAME', '[ Logic | Mainstage ] Default is Logic') do |n|
      n_up = n.upcase
      if %w[LOGIC MAINSTAGE].include?(n_up)
        LpxLinks.app_name = n_up
      else
        print "Application name can only be Logic or Mainstage\n"
        puts opts
        exit
      end
    end
    opts.on('-h', '--help', 'Prints this help') do
      puts opts
      exit
    end
  end.parse!

  def run
    create_dirs
    convert_plist_to_json
    print_file(FileHelpers.all_download_links, download_links)
    print_file(FileHelpers.mandatory_download_links, download_links(only_mandatory: true))
    print_file(FileHelpers.json_file, JSON.pretty_generate(packages))
    open_lpx_download_links
  rescue RuntimeError => e
    puts "Error: #{e.message}"
    puts "Please ensure that #{LpxLinks.app_name} is installed correctly on your system."
    exit 1
  end

  def open_lpx_download_links
    `open #{FileHelpers.links_dir}`
  end

  def create_dirs
    FileUtils.mkdir_p(FileHelpers.links_dir)
    FileUtils.mkdir_p(FileHelpers.json_dir)
  end

  def convert_plist_to_json
    `plutil -convert json \'#{FileHelpers.plist_file_path(LpxLinks.app_name)}\' -o /tmp/lgp_content.json`
  end

  def packages
    @packages ||= read_packages
  end

  def read_packages
    JSON.parse(File.read('/tmp/lgp_content.json'))['Packages']
  end

  def download_links(only_mandatory: false)
    links = []
    packages.each do |i|
      next if only_mandatory && !i[1]['IsMandatory']

      # Use File.join to concatenate URL and remove redundant separators (i.e. //)
      unresolved_download_url = File.join(FileHelpers.url, i[1]['DownloadName'])

      # Convert to URI
      download_uri = URI(unresolved_download_url)

      # Extract path
      unresolved_download_uri_path = download_uri.path

      # Resolve "../../" relative paths in the download URI path
      resolved_download_uri_path = Pathname.new(unresolved_download_uri_path).cleanpath.to_s

      # Set download URI path to the resolved path
      download_uri.path = resolved_download_uri_path

      # Convert download URI to URL string
      resolved_download_url = download_uri.to_s

      # Add the resolved download URL to the array
      links << "#{resolved_download_url}\n"
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
