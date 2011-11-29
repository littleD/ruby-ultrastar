require 'sinatra'
require 'shotgun'
require 'yaml'
require 'haml'
require 'lib.rb'
require 'open-uri'
require 'nokogiri'

config = YAML::load(File.open('config.yaml', 'r').read)

set :public, File.dirname(__FILE__) + '/public'

get '/' do
	songdirs = []
	config[:dirs].each {|dir|
		songdirs += [SongDir.new("",dir)]
	}
	@songdirs = songdirs
	haml :index
end

post'/' do
	newpath = params[:path]+'/'+params[:categories]
#	name = params[:old_path].split("/")[-1]
	FileUtils.mkdir_p newpath if !File.directory? newpath 	
	FileUtils.mv(params[:old_path],newpath)
	redirect '/' 
end

post'/s' do
  query = Nokogiri::HTML(open("http://gdata.youtube.com/feeds/api/videos?q="+params[:q].gsub(" ", "%20")))
	@title = query.css('title')
	@result = query.css('link[rel="alternate"]')
	erb :search
end


