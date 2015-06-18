#!/usr/bin/env ruby

require_relative './lib/config'
require 'json'

`plutil -convert json \'#{PLIST}\' -o #{JSN}`
JSON.parse(File.read(JSN))[PKG].each {|i| ; @line << "#{File.join(URL, i[1][DLN])}\n"}
f = File.open(LST, 'a') ;  f.puts @line.sort ; f.close
puts "Done! Found #{@line.to_a.length} links.\nCheck the following file:\n#{LSTs}"