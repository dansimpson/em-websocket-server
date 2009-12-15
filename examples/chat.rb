$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'em-websocket-server'
require 'json'

$chatroom = EM::Channel.new

class ChatServer < WebSocketServer

	def on_connect
		@sid = $chatroom.subscribe do |msg|
			send_message msg
		end
	end

	def on_disconnect
		$chatroom.unsubscribe(@sid)
	end

	def on_receive msg
		$chatroom.push msg
	end

end


EM.epoll
EM.set_descriptor_table_size(10240)

EM.run do
	EM.start_server "0.0.0.0", 8000, ChatServer
end