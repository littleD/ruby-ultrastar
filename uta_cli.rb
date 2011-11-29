#!/usr/bin/env ruby
$KCODE = 'UTF8' 

require 'lib.rb'
require 'htmlview.rb'

sd = SongDir.new("","/media/Kuroneko/UltraStar Deluxe/Songs/")

case ARGV[0] 
when "html"
	gen_html_view songdir 
when "songs"
	songs = sd.songs_recursive
	songs.sort! {|x,y| x.artist_title <=> y.artist_title }
	songs.each { |song|
		puts "#{song.artist_title}"
	}
when "problems"
	sd.songs_recursive.each { |song|
		puts "#{song}" if not song.problems.empty?
	}
end
