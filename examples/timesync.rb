$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'em-websocket-server'
require 'json'

class TimeServer < WebSocketServer

	def on_connect
		@timer = EM.add_periodic_timer(5) do
			sync_time
		end
	end

	def on_disconnect
		@timer
	end

	def on_receive msg
		puts "msg rcv"
	end

	def sync_time
		send_message({ :time => Time.now }.to_json)
	end

end


EM.epoll
EM.set_descriptor_table_size(10240)

EM.run do
	EM.start_server "0.0.0.0", 8000, TimeServer
end