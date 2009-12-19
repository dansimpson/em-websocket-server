require 'rubygems'
require 'eventmachine'

class WebSocketServer < EM::Connection

	@@logger			= nil
	@@num_connections	= 0
	@@path_regex 		= /^GET (\/[^\s]*) HTTP\/1\.1$/
	@@header_regex 		= /^([^:]+):\s*([^$]+)/
	@@callbacks 		= {}
	@@accepted_origins	= []

	attr_accessor	:connected,
					:headers,
					:path

	def initialize *args
		super
		@connected = false
	end

	def valid_origin?
		@@accepted_origins.empty? || @@accepted_origins.include?(origin)
	end

	#not doing anything with this yet
	def valid_path?
		true
	end

	def valid_upgrade?
		@headers["Upgrade"] =~ /websocket/i
	end

	def origin
		@headers["Origin"]
	end

	def host
		@headers["Host"]
	end

	def self.path name, &block
		@@callbacks[name] = block
	end

	#tcp connection established
	def post_init
		@@num_connections += 1
	end

	#must be public for em
	def unbind
		@@num_connections -= 1
		on_disconnect
	end

	# Frames need to start with 0x00-0x7f byte and end with 
	# an 0xFF byte.  Per spec, we can also set the first
	# byte to a value betweent 0x80 and 0xFF, followed by
	# a leading length indicator.  No support yet
	def send_message msg
		send_data "\x00#{msg}\xff"
	end

	protected

	#override this method
	def on_receive msg
		log msg
	end

	#override this method
	def on_connect
		log "connected"
	end

	#override this method
	def on_disconnect
		log "disconnected"
	end

	def log msg
		if @@logger
			@@logger.info msg
		else
			puts msg
		end
	end

	private

	# when the connection receives data from the client
	# we either handshake or handle the message at 
	# the app layer
	def receive_data data
		unless @connected
			handshake data
		else
			on_receive data.gsub(/^(\x00)|(\xff)$/, "")
		end
	end

	# parse the headers, validate the origin and path
	# and respond with appropiate headers for a 
	# healthy relationship with the client
	def handshake data

		#convert the headers to a hash
		parse_headers data

		# close the connection if the connection
		# originates from an invalid source
		close_connection unless valid_origin?

		# close the connection if a callback
		# is not registered for the path
		close_connection unless valid_path?

		# don't respond to non-websocket HTTP requests
		close_connection unless valid_upgrade?

		#complete the handshake
		send_headers

		@connected = true
		
		on_connect
	end

	# send the handshake response headers to
	# complete the initial com
	def send_headers

		response = "HTTP/1.1 101 Web Socket Protocol Handshake\r\n"
		response << "Upgrade: WebSocket\r\n"
		response << "Connection: Upgrade\r\n"
		response << "WebSocket-Origin: #{origin}\r\n"
		response << "WebSocket-Location: ws://#{host}#{path}\r\n\r\n"

		send_data response
	end

	# turn http style headers into a ruby hash
	# TODO: this is probably not done "well"
	def parse_headers data
		lines = data.split("\r\n")

		@path 	 = @@path_regex.match(lines.shift)[1]
		@headers = {}

		lines.each do |line|
			kvp = @@header_regex.match(line)
			@headers[kvp[1].strip] = kvp[2].strip
		end
	end

end