module WebSocket

	class Util

		@@path_regex    = /^GET (\/[^\s]*) HTTP\/1\.1$/
		@@hs_regex      = /^HTTP\/1\.1 101 Web Socket Protocol Handshake$/
		@@header_regex  = /^([^:]+):\s*([^$]+)/

		# Parse http style headers into a ruby hash
		def self.parse_headers data
			lines = data.split("\r\n")
      line  = lines.shift
      
			headers = {}
      
      case line
      when @@path_regex
        headers[:path] = @@path_regex.match(line)[1]
      when @@hs_regex
        #do nothing
      else
        throw "Unrecognized Header!"
      end
      
      
			lines.each do |line|
				kvp = @@header_regex.match(line)
				headers[kvp[1].strip.downcase.to_sym] = kvp[2].strip
			end

			headers
		end

		# encode ruby hash into HTTP style headers
		def self.encode_headers data
			result = ""

			data.each_pair do |k,v|
				result << k.to_s
				result << ": "
				result << v.to_s
				result << "\r\n"
			end

			result << "\r\n"
			result
		end
	  
  end
end