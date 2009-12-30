module WebSocket

	class Frame

		# Frames need to start with 0x00-0x7f byte and end with 
		# an 0xFF byte.  Per spec, we can also set the first
		# byte to a value betweent 0x80 and 0xFF, followed by
		# a leading length indicator.  No support yet.
		def self.encode data
			"\x00#{data}\xff"
		end

		# Strip leading and trailing bytes
		def self.decode data
			data.gsub(/^(\x00)|(\xff)$/, "")
		end

	end

end