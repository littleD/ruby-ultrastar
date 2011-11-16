module Problem
  ConfigNotFound = 0
	ConfigNoArtist = 1
	ConfigNoTitle = 2
	ConfigNoMP3 = 3
	ConfigNoMP3File = 4
  def self.name(problem)
		return "Config Not Found" if problem == ConfigNotFound
		return "Config: No Artist" if problem == ConfigNoArtist
		return "Config: No Title" if problem == ConfigNoTitle
		return "Config: No MP3" if problem == ConfigNoMP3
		return "Config: No MP3 File" if problem == ConfigNoMP3File
		return "You've gotta problem with problem"
  end
end

class SongDir
	attr_accessor :subdir, :file, :path, :root_dir

	def self.type(path)
		if Dir.glob("#{path}/**.txt") != []
			return :song
#			@txt = File.open(config[0]).read
		end
		return :container
	end

	def initialize(path,root_dir)
		@root_dir = root_dir
		@path = path
		@subdir = []
		@file = []
		recursive_scan
	end

	def recursive_scan
	  content = Dir.entries(path_abs)
		content -= ["..","."]
		content.each do |entry|
			short = "#{path}/#{entry}"
			long = "#{self.path_abs}/#{entry}"
			if File.directory?(long)
				if SongDir.type(long) == :song
					@file += [Song.new(short,root_dir)]
				else
					@subdir += [SongDir.new(short,root_dir)]
				end
			end
		end
	end

	def path_abs
		return "#{@root_dir}#{@path}"
	end

	def songs_recursive
		out = @file
		@subdir.each { |dir|
			out += dir.songs_recursive 
		}
		return out
	end

	def to_html
		return "
<div class=\"container\">
	<h1><img class=\"ico\" src=\""+(subdir == [] ? 'icons\folder_closed.png' : 'icons\folder_download_closed.png' ) +
"\">#{path}</h1> <div class=\"content\">#{subdir.join(' ')}</div>"+
	(@file ==[] ? "" : "<div class=\"song\"> #{@file.join("")}</div>")+
	" </div>"
	end
end

class Song
	attr_accessor :txt, :path, :title, :config,:bpm_file

	def initialize(path,root_dir)
		@path = path
		@root_dir = root_dir
		@problems = []
		if (config = Dir.glob("#{self.path_abs}/**.txt")) != []
			@txt = File.open(config[0]).read
		else
			@problems += [Problem::ConfigNotFound]
		end
		@config = {}
		@txt.scan(/#([A-Z0-9]*):(.*)/) {
			@config[$1] = $2
		}
		check_config
	end

	def check_config 
		@problems += [Problem::ConfigNoArtist] if @config['ARTIST'].nil?
		@problems += [Problem::ConfigNoTitle] if @config['TITLE'].nil?
		@problems += [Problem::ConfigNoMP3] if @config['MP3'].nil?
		@problems += [Problem::ConfigNoMP3File] if Dir.glob("#{self.path_abs}/#{@config['MP3']}") == []
	end

	def path_abs
		return "#{@root_dir}#{@path}"
	end

	def categories
		@path.split("/")[1..-2].join " "
	end

	def artist_title
		return "[#{@path}]" if @problems.include? Problem::ConfigNoArtist or @problems.include? Problem::ConfigNoTitle
		return "#{@config['ARTIST'].strip} - #{@config['TITLE'].strip}"
	end

	def prettier_config
		out = ""
		@config.each{|key, value|
			out+= "#{key} : #{value}"
		}
		out
	end

	def to_html
		out = ""
		if @config['MP3'].nil?
			out =  "<div class=\"unavalible\"><p>#{path} - brak pliku</p></div>" 
		else		
			out = 
	"
	<div><p><img class=\"ico\" src=\"icons\\microphone.png\">#{artist_title}</p></div>"
		end
		out
	end
	def mp3_path
		return "#{self.path_abs}/#{@config['MP3']}"
	end
	def to_s
		out = "#{artist_title}"

		out += "\n#{mp3_path}"
		out += "\n"+File.exists?(mp3_path).to_s
		@problems.each{ |problem| 
			out +="\n\t#{Problem.name(problem)}"
		} if @problems != []
		out
	end

	def lyrics
		lyrics = []; line = []
		@txt.scan(/(.) ([0-9]+)( (-?[0-9]+) (-?[0-9]+) (.*))?/) do
			if $1 == "-"
				lyrics += [line]; line = []
			else
				type = $1
				time = $2.to_i
				t1 = $3
				t2 = $4
				text = $6[0..-2]
				bpmt = (@config['BPM'].gsub(",",".")).to_f
				bpm = 14800.0/bpmt
				gap = @config['GAP'].to_i
				line += [{:type => type, :time => (time*bpm)+gap, :t1 => t1, :t2 => t2, :text => text}]
			end
		end
		lyrics += [line]

		out = ""; gap = false
		lyrics.each{ |line|
			out += "<div class=\"line\">\n"
			if gap == false
				out += "<span data-time=\"0\"></span>\n"
				gap = true
			end
			line.each{ |event|
				out += "<span data-time=\"#{event[:time]}\">#{event[:text]}</span>"
			}
			out += "\n</div>\n"
		}
		return out
	end

	def self.player(mp3)
		id = rand(10000)
		return "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0\" width=\"0\" height=\"0\" id=\"niftyPlayer#{id}\" align=\"\">
		 <param name=movie value=\"swf/niftyplayer.swf?file=#{mp3}&as=0\">
		 <param name=quality value=high>
		 <param name=bgcolor value=#FFFFFF>
		 <embed src=\"swf/niftyplayer.swf?file=#{mp3}&as=0\" quality=high bgcolor=#FFFFFF width=\"0\" height=\"0\" name=\"niftyPlayer#{id}\" align=\"\" type=\"application/x-shockwave-flash\" swLiveConnect=\"true\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\">
		</embed>
		</object>"
	end


# Wersja z playerem
#	def to_s
#		out = ""
#		if @config['MP3'].nil?
#			out =  "<div class=\"unavalible\"><p>#{path} - brak pliku</p></div>" 
#		else		
#			out = 
#	"<div class=\"song\">
#	<h1>#{artist_title}</h1>
#	#{Song.player(path_abs[1..-1].gsub(/\/public\//,"/")+'/'+@config['MP3'][0..-2])}
#	<div class=\"categories\">
#	<img src=\"/images/icons/folder_edit.png\" />
#	<span>#{self.categories}</span>
#	<form name=\"song\" action=\".\" method=\"post\">
#	<input type=\"hidden\" name=\"path\" value=\"#{@root_dir}\"/>
#	<input type=\"hidden\" name=\"old_path\" value=\"#{path_abs}\"/>
#	<input type=\"text\" name=\"categories\" value=\"#{self.categories}\"/>
#	</form>
#	</div>
#	"+
##	<p><button class=\"settings\">Settings</button><input type="text" name="gap"/><input type="text" name=""/></p>
#	"<div class=\"debug\">
#		<a href=\"#{path_abs.gsub(/\/public\//,"/")}/#{@config['MP3']}\">song</a>
#		<pre>#{self.prettier_config}</pre>
#	</div>\n"+
## "<pre>#{@txt}</pre>"+
#	"<button class=\"play\">Play</button>
#	<input type=\"hidden\" name=\"q\" value=\"#{artist_title}\"/>
#	<button type=\"submit\" class=\"search\">Search</button>
#	<button class=\"b_debug\">Debug</button>
#	<div class=\"lyrics\">#{self.lyrics}</div>\n</div>\n" 
#		end
#		out
#	end
end
