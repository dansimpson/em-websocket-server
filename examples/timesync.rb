$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'web_socket'
require 'json'

class TimeServer < WebSocket::Server

	def on_connect
	  puts "Connection Accepted"
		@timer = EM.add_periodic_timer(5, EM.Callback(self, :sync_time))
	end

	def on_disconnect
	  puts "Connection released"
		EM.cancel_timer @timer
	end

	def on_receive msg
	end

	def sync_time
	  puts "Hi"
		send_message({ :time => Time.now }.to_json)
	end

end


EM.epoll  = true if EM.epoll?
EM.kqueue = true if EM.kqueue?

EM.set_descriptor_table_size(10240)

EM.run do
	EM.start_server "0.0.0.0", 8000, TimeServer
end