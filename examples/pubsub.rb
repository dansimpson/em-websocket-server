$:.unshift File.dirname(__FILE__) + "/../lib"

require "rubygems"
require "em-websocket-server"
require "pp"

class PubServer < EM::WebSocket::Server

  flash_policy File.dirname(__FILE__) + "/crossdomain.xml"

	def on_connect
		@sid = Hub.subscribe do |msg|
			send_message msg
		end
		EM::WebSocket::Log.debug "Connected"
	end

	def on_disconnect
		Hub.unsubscribe(@sid)
		EM::WebSocket::Log.debug "Disconnected"
	end

	def on_receive msg
	  Hub.push msg
	end

end

class SecPubServer < PubServer
    secure
end

EM.kqueue = true if EM.kqueue?
EM.epoll  = true if EM.epoll?
EM.set_descriptor_table_size 8192

EM.run do
  Hub = EM::Channel.new
	EM.start_server "0.0.0.0", 8000, PubServer
	EM.start_server "0.0.0.0", 8001, SecPubServer
end