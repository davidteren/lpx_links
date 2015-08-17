#!/usr/bin/env ruby

require_relative './lib/config'
require 'json'

`plutil -convert json \'#{PLIST}\' -o #{JSN}`
JSON.parse(File.read(JSN))[PKG].each do |i|
  @line << "#{File.join(URL, i[1][DLN])}\n"
end
f = File.open(LST, 'w')
f.puts @line.sort
f.close
File.delete(JSN)
puts "Done! Found #{@line.to_a.length} links.
Check the following file:
#{LST}"
