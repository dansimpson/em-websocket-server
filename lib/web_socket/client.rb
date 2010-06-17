
module WebSocket

	class Client < EM::Connection

		def path
			"/chat"
		end
		
		def host
			"localhost:8000"
		end

		def origin
			"localhost"
		end
		
		# em override
		def post_init
			@connected = false
		end
		
		def connection_completed
			send_headers
		end

		# em override
		def unbind
			on_disconnect
		end

		def on_disconnect
		end

		def send_message msg
			send_data Frame.encode(msg)
		end

		private
		
		def receive_data data
			unless @connected
				handshake data
			else
        while msg = data.slice!(/\000([^\377]*)\377/)
          on_receive Frame.decode(msg)
        end
			end
		end

		def handshake data

			#convert the headers to a hash
			@headers   = Util.parse_headers(data)
			@connected = true

			on_connect
		end

		def send_headers
			result = "GET #{path} HTTP/1.1\r\n"
			result << "Upgrade: WebSocket\r\n"
			result << "Connection: Upgrade\r\n"
			result << "Host: #{host}\r\n"
			result << "Origin: #{origin}\r\n\r\n"

			send_data result
		end
	end

end