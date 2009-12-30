$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'web_socket'
require 'json'

$chatroom = EM::Channel.new
$messages = 0

class ChatServer < WebSocket::Server

	def on_connect
	  puts "Server -> Connect"
		@sid = $chatroom.subscribe do |msg|
			send_message msg
		end
	end

	def on_disconnect
	  puts "Server -> Handle Disconnect"
		$chatroom.unsubscribe(@sid)
	end

	def on_receive msg
	  
	  $messages += 1
	  if($messages % 100 == 0)
      puts $messages
    end

		$chatroom.push(msg)
	end

end

class ChatClient < WebSocket::Client

  def initialize *args
    super
  end

	def on_disconnect
		puts "Client -> Disconnected"
	end

	def on_connect
		
		EM.add_periodic_timer(rand() * 8, EM.Callback(self, :on_timer))

		puts "Client -> connected"

	end
	
	def on_timer
	  send_message "x"
	end

	def on_receive msg
	end

end

EM.kqueue

EM.run do
	EM.start_server "0.0.0.0", 8000, ChatServer
	5.times do
	  EM.connect "localhost", 8000, ChatClient
  end
end