#!/usr/bin/env ruby

require_relative './lib/config'
require 'json'
require 'fileutils'

# read the plist, create a json & parse a list of links
module GetLinks

  def launch
  	create_dirs
    plist_to_json
    json_parse
    print_file
    del_temp_files
    end_msg
  end

  def create_dirs
  	[DWN_LNK, INSTALS].each do |dir|
  		FileUtils.mkdir_p(dir)
  	end
  end

  def plist_to_json
    `plutil -convert json \'#{PLIST}\' -o #{JSN}`
  end

  def json_parse
    JSON.parse(File.read(JSN))[PKG].each do |i|
      @line << "#{File.join(URL, i[1][DLN])}\n"
    end
  end

  def print_file
    f = File.open(DWN_LST, 'w')
    f.puts @line.sort
    f.close
  end

  def del_temp_files
    File.delete(JSN)
  end

  def end_msg
    puts "Done! Found #{@line.to_a.length} links.
    Check the following file: #{DWN_LST}"
    `cd #{File.join(DWN_LNK)} ; open .`
  end
end

include GetLinks
launch
