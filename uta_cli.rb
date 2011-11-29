#!/usr/bin/env ruby
$KCODE = 'UTF8' 

require 'yaml'
require 'lib.rb'
require 'htmlview.rb'

config = YAML::load(File.open('config.yaml', 'r').read)
dir = config[:dirs][0]                                         #TODO - only first dir
sd = SongDir.new("", dir )

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
