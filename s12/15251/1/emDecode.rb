class EmDecode
@instructions = ["uparrow", "rightarrow", "lhd", "rhd"]
	def incPC
		@pc += 1 unless pc <= @progCountLimit
	end
	def decPC
		@pc -= 1 unless pc >= 0
	end
	def initialize
		@tape = []
		@bytecode
		puts "Reading the file..."
		file = File.new("mystery.em", "r")
		tapeString = file.gets
		puts "Parsing the file"
		@bytecode = tapeString.split('\\') # splits at \. two for escaping
		@progCountLimit = @bytecode.size
## begin interpreting
		@tapeCount = 0
		@bytecode.each  do |t|
			if t.eql?("uparrow")
			@tape[@tapeCount] = 0 unless !@tape[@tapeCount].nil?
				@tape[@tapeCount] += 1
			end
			if t.eql?("rightarrow")
			@tape[@tapeCount] = 0 unless !@tape[@tapeCount].nil?
				@tapeCount += 1
			end
			if t.eql?("lhd")
				STDOUT.flush
				ascii = 0
				ascii = STDIN.gets.bytes.to_a[0].ord
				@tape[@tapeCount] = ascii
			end
			if t.eql?("rhd")
				print @tape[@tapeCount].chr unless @tape[@tapeCount].nil? || @tape[@tapeCount] > 128
			end

		end
	end
end

em = EmDecode.new

