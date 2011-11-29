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
	attr_accessor :subdirs, :songs, :path, :root_dir

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
		@subdirs = []
		@songs = []
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
					@songs += [Song.new(short,root_dir)]
				else
					@subdirs += [SongDir.new(short,root_dir)]
				end
			end
		end
	end

	def path_abs
		return "#{@root_dir}#{@path}"
	end

	def songs_recursive
		out = @songs
		@subdirs.each { |dir|
			out += dir.songs_recursive 
		}
		return out
	end

	def to_html
    Haml::Engine.new(File.open("views/songdir.haml").read).render '', :songdir => self.clone
	end
end

class Song
	attr_accessor :txt, :path, :title, :config, :bpm_file, :problems, :artist

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
		@txt.scan(/#([A-Z0-9]*):(.*)\r/) {
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

	def artist 
		@config['ARTIST']
	end

	def title
		@config['TITLE']
	end

	def artist_title
		return "[#{@path}]" if @problems.include? Problem::ConfigNoArtist or @problems.include? Problem::ConfigNoTitle
		return "#{@config['ARTIST'].strip} - #{@config['TITLE'].strip} [#{@path}]"
	end

	def prettier_config
		out = ""
		@config.each{|key, value|
			out+= "#{key} : #{value}"
		}
		out
	end

	def to_html
    Haml::Engine.new(File.open("views/song.haml").read).render '', :song => self.clone
	end

	def mp3_path
		return "#{self.path_abs}/#{@config['MP3']}"
	end

	def to_s
		out = "#{artist_title}"
		@problems.each{ |problem| 
			out +="\n\t#{Problem.name(problem)}"
			out += "\n\t:#{@config['MP3']}"	if problem == Problem::ConfigNoMP3File 
		} if not @problems.empty?
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
end
