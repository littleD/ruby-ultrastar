#!/usr/bin/env ruby

require 'lib.rb'
require 'htmlview.rb'

sd = SongDir.new("","public/uta")

if ARGV[0] == "html"
	gen_html_view songdir 
end
if ARGV[0] == "songs"
	sd.songs_recursive.each{ |song|
		puts "#{song}"
	}
end
